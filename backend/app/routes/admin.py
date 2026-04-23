import os
import uuid
from pathlib import Path

from flask import Blueprint, request, jsonify, current_app
from marshmallow import ValidationError
from werkzeug.utils import secure_filename

from ..extensions import db
from ..auth import admin_required
from ..models import (
    Category,
    ProductType,
    Product,
    Image,
    Order,
    User,
    ORDER_STATUSES,
)
from ..schemas import (
    CategoryIn,
    CategoryOut,
    ProductTypeIn,
    ProductTypeOut,
    ProductIn,
    ProductOut,
    OrderOut,
    AdminStatusUpdate,
    UserOut,
)

bp = Blueprint("admin", __name__)

category_in = CategoryIn()
category_out = CategoryOut()
type_in = ProductTypeIn()
type_out = ProductTypeOut()
product_in = ProductIn()
product_out = ProductOut()
order_out = OrderOut()
status_update = AdminStatusUpdate()
user_out = UserOut()


def _allowed_file(filename):
    ext = filename.rsplit(".", 1)[-1].lower() if "." in filename else ""
    return ext in current_app.config["ALLOWED_EXTENSIONS"]


def _save_uploaded_file(file_storage):
    safe = secure_filename(file_storage.filename or "")
    ext = safe.rsplit(".", 1)[-1].lower() if "." in safe else "jpg"
    name = f"{uuid.uuid4().hex}.{ext}"
    path = Path(current_app.config["UPLOAD_FOLDER"]) / name
    file_storage.save(str(path))
    return name


@bp.get("/categories")
@admin_required
def list_categories():
    items = Category.query.order_by(Category.id).all()
    return jsonify(items=[category_out.dump(c) for c in items])


@bp.post("/categories")
@admin_required
def create_category():
    try:
        data = category_in.load(request.get_json() or {})
    except ValidationError as err:
        return jsonify(errors=err.messages), 400

    if Category.query.filter_by(slug=data["slug"]).first():
        return jsonify(errors={"slug": ["Slug уже занят"]}), 400

    cat = Category(**data)
    db.session.add(cat)
    db.session.commit()
    return jsonify(item=category_out.dump(cat)), 201


@bp.put("/categories/<int:cat_id>")
@admin_required
def update_category(cat_id):
    cat = db.session.get(Category, cat_id)
    if not cat:
        return jsonify(error="Категория не найдена"), 404
    try:
        data = category_in.load(request.get_json() or {})
    except ValidationError as err:
        return jsonify(errors=err.messages), 400

    other = Category.query.filter(Category.slug == data["slug"], Category.id != cat_id).first()
    if other:
        return jsonify(errors={"slug": ["Slug уже занят"]}), 400

    cat.title = data["title"]
    cat.slug = data["slug"]
    db.session.commit()
    return jsonify(item=category_out.dump(cat))


@bp.delete("/categories/<int:cat_id>")
@admin_required
def delete_category(cat_id):
    cat = db.session.get(Category, cat_id)
    if not cat:
        return jsonify(error="Категория не найдена"), 404
    if cat.products:
        return jsonify(error="В категории есть товары — сначала удалите их"), 400
    db.session.delete(cat)
    db.session.commit()
    return jsonify(ok=True)


@bp.get("/product-types")
@admin_required
def list_types():
    items = ProductType.query.order_by(ProductType.id).all()
    return jsonify(items=[type_out.dump(t) for t in items])


@bp.post("/product-types")
@admin_required
def create_type():
    try:
        data = type_in.load(request.get_json() or {})
    except ValidationError as err:
        return jsonify(errors=err.messages), 400
    t = ProductType(**data)
    db.session.add(t)
    db.session.commit()
    return jsonify(item=type_out.dump(t)), 201


@bp.put("/product-types/<int:type_id>")
@admin_required
def update_type(type_id):
    t = db.session.get(ProductType, type_id)
    if not t:
        return jsonify(error="Тип не найден"), 404
    try:
        data = type_in.load(request.get_json() or {})
    except ValidationError as err:
        return jsonify(errors=err.messages), 400
    t.title = data["title"]
    db.session.commit()
    return jsonify(item=type_out.dump(t))


@bp.delete("/product-types/<int:type_id>")
@admin_required
def delete_type(type_id):
    t = db.session.get(ProductType, type_id)
    if not t:
        return jsonify(error="Тип не найден"), 404
    if t.products:
        return jsonify(error="К типу привязаны товары"), 400
    db.session.delete(t)
    db.session.commit()
    return jsonify(ok=True)


@bp.get("/products")
@admin_required
def list_products():
    items = Product.query.order_by(Product.id.desc()).all()
    return jsonify(items=[product_out.dump(p) for p in items])


@bp.post("/products")
@admin_required
def create_product():
    try:
        data = product_in.load(request.get_json() or {})
    except ValidationError as err:
        return jsonify(errors=err.messages), 400

    if not db.session.get(Category, data["category_id"]):
        return jsonify(errors={"category_id": ["Категория не найдена"]}), 400
    if not db.session.get(ProductType, data["product_type_id"]):
        return jsonify(errors={"product_type_id": ["Тип не найден"]}), 400

    p = Product(**data)
    db.session.add(p)
    db.session.commit()
    return jsonify(item=product_out.dump(p)), 201


@bp.put("/products/<int:pid>")
@admin_required
def update_product(pid):
    p = db.session.get(Product, pid)
    if not p:
        return jsonify(error="Товар не найден"), 404
    try:
        data = product_in.load(request.get_json() or {})
    except ValidationError as err:
        return jsonify(errors=err.messages), 400

    for k, v in data.items():
        setattr(p, k, v)
    db.session.commit()
    return jsonify(item=product_out.dump(p))


@bp.delete("/products/<int:pid>")
@admin_required
def delete_product(pid):
    p = db.session.get(Product, pid)
    if not p:
        return jsonify(error="Товар не найден"), 404

    upload_dir = Path(current_app.config["UPLOAD_FOLDER"])
    for img in p.images:
        f = upload_dir / img.filename
        if f.exists():
            try:
                f.unlink()
            except OSError:
                pass

    db.session.delete(p)
    db.session.commit()
    return jsonify(ok=True)


@bp.post("/products/<int:pid>/images")
@admin_required
def upload_product_image(pid):
    p = db.session.get(Product, pid)
    if not p:
        return jsonify(error="Товар не найден"), 404

    file = request.files.get("file")
    if not file or not file.filename:
        return jsonify(error="Файл не передан"), 400
    if not _allowed_file(file.filename):
        return jsonify(error="Допустимые форматы: png, jpg, jpeg, webp"), 400

    filename = _save_uploaded_file(file)
    next_sort = (
        db.session.query(db.func.coalesce(db.func.max(Image.sort_order), -1))
        .filter(Image.product_id == pid)
        .scalar()
    ) + 1
    img = Image(product_id=pid, filename=filename, sort_order=next_sort)
    db.session.add(img)
    db.session.commit()
    return jsonify(
        image={
            "id": img.id,
            "filename": img.filename,
            "sort_order": img.sort_order,
            "url": f"/uploads/products/{img.filename}",
        }
    ), 201


@bp.delete("/images/<int:image_id>")
@admin_required
def delete_image(image_id):
    img = db.session.get(Image, image_id)
    if not img:
        return jsonify(error="Картинка не найдена"), 404

    f = Path(current_app.config["UPLOAD_FOLDER"]) / img.filename
    if f.exists():
        try:
            f.unlink()
        except OSError:
            pass

    db.session.delete(img)
    db.session.commit()
    return jsonify(ok=True)


@bp.get("/orders")
@admin_required
def list_orders():
    items = Order.query.order_by(Order.created_at.desc()).all()
    return jsonify(
        items=[
            {
                **order_out.dump(o),
                "user": {
                    "id": o.user.id,
                    "full_name": o.user.full_name,
                    "login": o.user.login,
                    "phone": o.user.phone,
                },
            }
            for o in items
        ]
    )


@bp.get("/orders/<int:oid>")
@admin_required
def get_order(oid):
    o = db.session.get(Order, oid)
    if not o:
        return jsonify(error="Заказ не найден"), 404
    return jsonify(
        order={
            **order_out.dump(o),
            "user": {
                "id": o.user.id,
                "full_name": o.user.full_name,
                "login": o.user.login,
                "phone": o.user.phone,
            },
        }
    )


@bp.patch("/orders/<int:oid>/status")
@admin_required
def change_status(oid):
    o = db.session.get(Order, oid)
    if not o:
        return jsonify(error="Заказ не найден"), 404
    try:
        data = status_update.load(request.get_json() or {})
    except ValidationError as err:
        return jsonify(errors=err.messages), 400

    o.status = data["status"]
    db.session.commit()
    return jsonify(order=order_out.dump(o))


@bp.get("/statuses")
@admin_required
def statuses():
    from ..models import ORDER_STATUS_LABELS
    return jsonify(
        items=[
            {"value": s, "label": ORDER_STATUS_LABELS[s]} for s in ORDER_STATUSES
        ]
    )


@bp.get("/users")
@admin_required
def list_users():
    items = User.query.order_by(User.id).all()
    return jsonify(items=[user_out.dump(u) for u in items])
