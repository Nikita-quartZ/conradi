import os
import re
import shutil
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
REBUILD_ROOT = SCRIPT_DIR.parent
_candidates = [Path("/app"), REBUILD_ROOT / "backend"]
BACKEND_DIR = next((p for p in _candidates if (p / "app" / "__init__.py").exists()), _candidates[-1])
sys.path.insert(0, str(BACKEND_DIR))

os.chdir(BACKEND_DIR)

from app import create_app  # noqa: E402
from app.extensions import db  # noqa: E402
from app.models import Category, ProductType, Product, Image  # noqa: E402


OLD_DUMP = Path(os.getenv("OLD_DUMP_PATH", SCRIPT_DIR / "dump.sql"))
DEFAULT_IMG_DIR = SCRIPT_DIR / "img"
LEGACY_IMG_DIR = REBUILD_ROOT.parent / "conradi" / "web" / "img"
OLD_IMG_DIR = Path(os.getenv("OLD_IMG_DIR", DEFAULT_IMG_DIR if DEFAULT_IMG_DIR.exists() else LEGACY_IMG_DIR))
NEW_IMG_DIR = Path(os.getenv("UPLOAD_FOLDER", BACKEND_DIR / "uploads" / "products"))


TRANSLIT = {
    "а": "a", "б": "b", "в": "v", "г": "g", "д": "d", "е": "e", "ё": "e",
    "ж": "zh", "з": "z", "и": "i", "й": "y", "к": "k", "л": "l", "м": "m",
    "н": "n", "о": "o", "п": "p", "р": "r", "с": "s", "т": "t", "у": "u",
    "ф": "f", "х": "h", "ц": "ts", "ч": "ch", "ш": "sh", "щ": "sch", "ъ": "",
    "ы": "y", "ь": "", "э": "e", "ю": "yu", "я": "ya",
}


def slugify(text):
    text = text.lower()
    out = []
    for c in text:
        if c in TRANSLIT:
            out.append(TRANSLIT[c])
        elif c.isalnum():
            out.append(c)
        elif c in " -_":
            out.append("-")
    return re.sub(r"-+", "-", "".join(out)).strip("-") or "category"


def parse_values_list(text):
    rows = []
    i, n = 0, len(text)
    while i < n:
        while i < n and text[i] in " \t\n\r,":
            i += 1
        if i >= n or text[i] != "(":
            break
        i += 1
        row = []
        while True:
            while i < n and text[i] in " \t\n\r,":
                i += 1
            if i >= n:
                break
            if text[i] == ")":
                i += 1
                rows.append(tuple(row))
                break
            ch = text[i]
            if ch in ("'", '"'):
                quote = ch
                i += 1
                buf = []
                while i < n:
                    c = text[i]
                    if c == "\\" and i + 1 < n:
                        nxt = text[i + 1]
                        if nxt == "n":
                            buf.append("\n")
                        elif nxt == "r":
                            buf.append("\r")
                        elif nxt == "t":
                            buf.append("\t")
                        elif nxt == "0":
                            buf.append("\x00")
                        else:
                            buf.append(nxt)
                        i += 2
                    elif c == quote:
                        if i + 1 < n and text[i + 1] == quote:
                            buf.append(quote)
                            i += 2
                        else:
                            i += 1
                            break
                    else:
                        buf.append(c)
                        i += 1
                row.append("".join(buf))
            elif ch.isdigit() or ch in "+-":
                start = i
                while i < n and (text[i].isdigit() or text[i] in ".+-eE"):
                    i += 1
                token = text[start:i]
                try:
                    row.append(int(token) if "." not in token and "e" not in token.lower() else float(token))
                except ValueError:
                    row.append(token)
            elif text[i:i + 4].upper() == "NULL":
                row.append(None)
                i += 4
            else:
                i += 1
    return rows


def parse_inserts(sql_text):
    i = 0
    n = len(sql_text)
    pattern = re.compile(
        r"INSERT\s+INTO\s+`(\w+)`\s*\(([^)]*)\)\s*VALUES\s+",
        re.IGNORECASE,
    )
    while i < n:
        m = pattern.search(sql_text, i)
        if not m:
            break
        table = m.group(1)
        cols = [c.strip().strip("`") for c in m.group(2).split(",")]
        start = m.end()
        j = start
        in_quote = None
        while j < n:
            c = sql_text[j]
            if in_quote:
                if c == "\\" and j + 1 < n:
                    j += 2
                    continue
                if c == in_quote:
                    in_quote = None
            else:
                if c in ("'", '"'):
                    in_quote = c
                elif c == ";":
                    break
            j += 1
        rows = parse_values_list(sql_text[start:j])
        yield table, cols, rows
        i = j + 1


def row_dict(cols, row):
    return dict(zip(cols, row))


def migrate():
    if not OLD_DUMP.exists():
        print(f"Дамп не найден: {OLD_DUMP}")
        sys.exit(1)
    if not OLD_IMG_DIR.exists():
        print(f"Папка с картинками не найдена: {OLD_IMG_DIR}")
        print("Товары перенесём, но без картинок.")

    sql = OLD_DUMP.read_text(encoding="utf-8")

    parsed = {}
    for table, cols, rows in parse_inserts(sql):
        parsed[table] = (cols, rows)
        print(f"  прочитано {table:14s} {len(rows):3d} строк")

    app = create_app()
    with app.app_context():
        if Category.query.first() or Product.query.first():
            print("База уже заполнена, миграция пропущена.")
            return

        slug_used = set()
        cats_cols, cats_rows = parsed["category"]
        for row in cats_rows:
            r = row_dict(cats_cols, row)
            slug = slugify(r["title"])
            base = slug
            counter = 2
            while slug in slug_used:
                slug = f"{base}-{counter}"
                counter += 1
            slug_used.add(slug)
            db.session.add(Category(id=r["id"], title=r["title"], slug=slug))
        db.session.flush()
        print(f"Категорий: {len(cats_rows)}")

        pt_cols, pt_rows = parsed["product_type"]
        for row in pt_rows:
            r = row_dict(pt_cols, row)
            db.session.add(ProductType(id=r["id"], title=r["title"]))
        db.session.flush()
        print(f"Типов товара: {len(pt_rows)}")

        p_cols, p_rows = parsed["product"]
        for row in p_rows:
            r = row_dict(p_cols, row)
            db.session.add(
                Product(
                    id=r["id"],
                    category_id=r["category_id"],
                    product_type_id=r["product_type_id"],
                    title=r["title"],
                    description=r.get("desciption") or "",
                    price=r["price"],
                    stock=r["count"],
                )
            )
        db.session.flush()
        print(f"Товаров: {len(p_rows)}")

        NEW_IMG_DIR.mkdir(parents=True, exist_ok=True)
        copied = 0
        if OLD_IMG_DIR.exists():
            def is_product_photo(f):
                if not (f.is_file() and f.suffix.lower() in (".jpg", ".jpeg", ".png")):
                    return False
                parts = f.stem.split("_", 1)
                return len(parts) == 2 and parts[0].isdigit() and len(parts[0]) >= 8

            fresh = sorted(f for f in OLD_IMG_DIR.iterdir()
                           if is_product_photo(f) and f.name.startswith("1769"))
            legacy = sorted(f for f in OLD_IMG_DIR.iterdir()
                            if is_product_photo(f) and not f.name.startswith("1769"))
            available = fresh + legacy

            products_sorted = sorted(Product.query.all(), key=lambda p: p.id)
            for prod, src in zip(products_sorted, available):
                shutil.copy2(src, NEW_IMG_DIR / src.name)
                db.session.add(
                    Image(product_id=prod.id, filename=src.name, sort_order=0)
                )
                copied += 1
            extra = len(products_sorted) - copied
            if extra > 0:
                print(f"{extra} товар(ов) остались без картинки — файлов в папке меньше")
        db.session.commit()
        print(f"Картинок скопировано: {copied}")
        print("Миграция завершена.")


if __name__ == "__main__":
    migrate()
