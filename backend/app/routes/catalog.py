from flask import Blueprint, request, jsonify
from sqlalchemy import or_

from ..extensions import db
from ..models import Category, ProductType, Product
from ..schemas import CategoryOut, ProductTypeOut, ProductOut

bp = Blueprint("catalog", __name__)

category_out = CategoryOut()
product_type_out = ProductTypeOut()
product_out = ProductOut()


@bp.get("/categories")
def categories():
    items = Category.query.order_by(Category.id).all()
    return jsonify(items=[category_out.dump(c) for c in items])


@bp.get("/product-types")
def product_types():
    items = ProductType.query.order_by(ProductType.id).all()
    return jsonify(items=[product_type_out.dump(t) for t in items])


@bp.get("/products")
def products():
    q = Product.query

    category_id = request.args.get("category_id", type=int)
    product_type_id = request.args.get("product_type_id", type=int)
    search = request.args.get("q", type=str)
    min_price = request.args.get("min_price", type=float)
    max_price = request.args.get("max_price", type=float)
    sort = request.args.get("sort", "newest")
    in_stock_only = request.args.get("in_stock", type=str) == "true"

    if category_id:
        q = q.filter(Product.category_id == category_id)
    if product_type_id:
        q = q.filter(Product.product_type_id == product_type_id)
    if search:
        like = f"%{search}%"
        q = q.filter(or_(Product.title.ilike(like), Product.description.ilike(like)))
    if min_price is not None:
        q = q.filter(Product.price >= min_price)
    if max_price is not None:
        q = q.filter(Product.price <= max_price)
    if in_stock_only:
        q = q.filter(Product.stock > 0)

    sort_map = {
        "price_asc": Product.price.asc(),
        "price_desc": Product.price.desc(),
        "newest": Product.id.desc(),
        "oldest": Product.id.asc(),
    }
    q = q.order_by(sort_map.get(sort, Product.id.desc()))

    page = max(request.args.get("page", 1, type=int), 1)
    per_page = min(max(request.args.get("per_page", 12, type=int), 1), 60)

    pagination = q.paginate(page=page, per_page=per_page, error_out=False)
    return jsonify(
        items=[product_out.dump(p) for p in pagination.items],
        page=pagination.page,
        per_page=pagination.per_page,
        total=pagination.total,
        pages=pagination.pages,
    )


@bp.get("/products/<int:product_id>")
def product_detail(product_id):
    product = db.session.get(Product, product_id)
    if not product:
        return jsonify(error="Товар не найден"), 404
    return jsonify(product=product_out.dump(product))


@bp.get("/products/popular")
def popular():
    limit = min(max(request.args.get("limit", 8, type=int), 1), 24)
    items = Product.query.order_by(Product.id.desc()).limit(limit * 2).all()
    items.sort(key=lambda p: (-p.average_rating, -p.id))
    return jsonify(items=[product_out.dump(p) for p in items[:limit]])
