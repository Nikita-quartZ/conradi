from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity

from ..extensions import db
from ..models import CartItem, Product
from ..schemas import CartItemOut

bp = Blueprint("cart", __name__)
cart_item_out = CartItemOut()


def _user_id():
    return int(get_jwt_identity())


def _items_payload(user_id):
    items = (
        CartItem.query.filter_by(user_id=user_id)
        .order_by(CartItem.id)
        .all()
    )
    total = sum(it.quantity * float(it.product.price) for it in items)
    count = sum(it.quantity for it in items)
    return {
        "items": [cart_item_out.dump(it) for it in items],
        "total": round(total, 2),
        "count": count,
    }


@bp.get("")
@jwt_required()
def get_cart():
    return jsonify(_items_payload(_user_id()))


@bp.post("")
@jwt_required()
def add_to_cart():
    data = request.get_json() or {}
    product_id = data.get("product_id")
    quantity = max(int(data.get("quantity", 1)), 1)

    product = db.session.get(Product, product_id) if product_id else None
    if not product:
        return jsonify(error="Товар не найден"), 404
    if product.stock <= 0:
        return jsonify(error="Товара нет в наличии"), 400

    uid = _user_id()
    existing = CartItem.query.filter_by(user_id=uid, product_id=product_id).first()
    if existing:
        existing.quantity = min(existing.quantity + quantity, product.stock)
    else:
        db.session.add(
            CartItem(
                user_id=uid,
                product_id=product_id,
                quantity=min(quantity, product.stock),
            )
        )
    db.session.commit()
    return jsonify(_items_payload(uid)), 201


@bp.patch("/<int:item_id>")
@jwt_required()
def update_cart_item(item_id):
    uid = _user_id()
    item = CartItem.query.filter_by(id=item_id, user_id=uid).first()
    if not item:
        return jsonify(error="Позиция не найдена"), 404

    data = request.get_json() or {}
    quantity = data.get("quantity")
    if quantity is None or int(quantity) < 1:
        return jsonify(error="Минимум 1 шт."), 400

    quantity = int(quantity)
    if quantity > item.product.stock:
        return jsonify(error=f"На складе только {item.product.stock} шт."), 400

    item.quantity = quantity
    db.session.commit()
    return jsonify(_items_payload(uid))


@bp.delete("/<int:item_id>")
@jwt_required()
def remove_cart_item(item_id):
    uid = _user_id()
    item = CartItem.query.filter_by(id=item_id, user_id=uid).first()
    if not item:
        return jsonify(error="Позиция не найдена"), 404
    db.session.delete(item)
    db.session.commit()
    return jsonify(_items_payload(uid))


@bp.delete("")
@jwt_required()
def clear_cart():
    uid = _user_id()
    CartItem.query.filter_by(user_id=uid).delete()
    db.session.commit()
    return jsonify(_items_payload(uid))
