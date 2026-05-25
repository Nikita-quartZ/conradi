from datetime import date, datetime, timedelta
from decimal import Decimal

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import ValidationError

from ..extensions import db
from ..models import CartItem, Order, OrderItem, Product
from ..schemas import CheckoutSchema, OrderOut

bp = Blueprint("orders", __name__)
checkout_schema = CheckoutSchema()
order_out = OrderOut()


def _user_id():
    return int(get_jwt_identity())


@bp.post("/checkout")
@jwt_required()
def checkout():
    try:
        data = checkout_schema.load(request.get_json() or {})
    except ValidationError as err:
        return jsonify(errors=err.messages), 400

    if data["delivery_date"] < date.today():
        return jsonify(errors={"delivery_date": ["Дата доставки в прошлом"]}), 400

    try:
        hour, minute = (int(p) for p in data["delivery_time"].split(":"))
        delivery_at = datetime.combine(
            data["delivery_date"], datetime.min.time()
        ).replace(hour=hour, minute=minute)
    except (ValueError, KeyError):
        return jsonify(errors={"delivery_time": ["Неверный формат времени"]}), 400

    if delivery_at < datetime.now() + timedelta(hours=1):
        return (
            jsonify(
                errors={
                    "delivery_time": [
                        "Доставка возможна минимум через 1 час от текущего времени"
                    ]
                }
            ),
            400,
        )

    uid = _user_id()
    cart = CartItem.query.filter_by(user_id=uid).all()
    if not cart:
        return jsonify(error="Корзина пуста"), 400

    issues = []
    for item in cart:
        if item.quantity > item.product.stock:
            issues.append(
                {
                    "product_id": item.product_id,
                    "title": item.product.title,
                    "requested": item.quantity,
                    "stock": item.product.stock,
                }
            )
    if issues:
        return jsonify(error="Недостаточно товара на складе", issues=issues), 400

    total = sum(it.quantity * it.product.price for it in cart)

    comment = data.get("customer_comment")
    if comment:
        comment = comment.strip() or None

    order = Order(
        user_id=uid,
        total=total,
        address=data["address"],
        pay_method=data["pay_method"],
        status="created",
        delivery_date=data["delivery_date"],
        delivery_time=data["delivery_time"],
        customer_comment=comment,
    )
    db.session.add(order)
    db.session.flush()

    for item in cart:
        db.session.add(
            OrderItem(
                order_id=order.id,
                product_id=item.product_id,
                title_snapshot=item.product.title,
                price_snapshot=item.product.price,
                quantity=item.quantity,
            )
        )
        item.product.stock -= item.quantity

    for item in cart:
        db.session.delete(item)

    db.session.commit()
    return jsonify(order=order_out.dump(order)), 201


@bp.get("")
@jwt_required()
def my_orders():
    orders = (
        Order.query.filter_by(user_id=_user_id())
        .order_by(Order.created_at.desc())
        .all()
    )
    return jsonify(items=[order_out.dump(o) for o in orders])


@bp.get("/<int:order_id>")
@jwt_required()
def order_detail(order_id):
    order = Order.query.filter_by(id=order_id, user_id=_user_id()).first()
    if not order:
        return jsonify(error="Заказ не найден"), 404
    return jsonify(order=order_out.dump(order))
