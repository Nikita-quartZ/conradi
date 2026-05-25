from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import ValidationError

from ..extensions import db
from ..models import Review, OrderItem, Order, Product, User
from ..schemas import ReviewIn, ReviewOut

bp = Blueprint("reviews", __name__)
review_in = ReviewIn()
review_out = ReviewOut()


ALLOWED_ORDER_STATUSES = ("issued", "delivered")


def _can_user_review(user_id, product_id):
    return (
        db.session.query(OrderItem)
        .join(Order, Order.id == OrderItem.order_id)
        .filter(
            Order.user_id == user_id,
            OrderItem.product_id == product_id,
            Order.status.in_(ALLOWED_ORDER_STATUSES),
        )
        .first()
        is not None
    )


@bp.get("/products/<int:product_id>/reviews")
def list_product_reviews(product_id):
    items = (
        Review.query.filter_by(product_id=product_id, is_hidden=False)
        .order_by(Review.created_at.desc())
        .all()
    )
    return jsonify(items=[review_out.dump(r) for r in items])


@bp.get("/products/<int:product_id>/reviews/can-leave")
@jwt_required()
def can_leave(product_id):
    uid = int(get_jwt_identity())
    return jsonify(allowed=_can_user_review(uid, product_id))


@bp.post("/products/<int:product_id>/reviews")
@jwt_required()
def create_review(product_id):
    uid = int(get_jwt_identity())
    product = db.session.get(Product, product_id)
    if not product:
        return jsonify(error="Товар не найден"), 404

    if not _can_user_review(uid, product_id):
        return (
            jsonify(error="Оставить отзыв можно только после получения заказа с этим товаром"),
            403,
        )

    existing = Review.query.filter_by(user_id=uid, product_id=product_id).first()
    if existing:
        return jsonify(error="Вы уже оставили отзыв на этот товар"), 400

    try:
        data = review_in.load(request.get_json() or {})
    except ValidationError as err:
        return jsonify(errors=err.messages), 400

    user = db.session.get(User, uid)
    review = Review(
        product_id=product_id,
        user_id=uid,
        author_name=user.full_name,
        stars=data["stars"],
        text=data["text"].strip(),
    )
    db.session.add(review)
    db.session.commit()
    return jsonify(review=review_out.dump(review)), 201


@bp.get("/reviews/promoted")
def promoted():
    items = (
        Review.query.filter_by(is_promoted=True, is_hidden=False)
        .order_by(Review.created_at.desc())
        .limit(8)
        .all()
    )
    return jsonify(
        items=[
            {
                **review_out.dump(r),
                "product": {
                    "id": r.product.id,
                    "title": r.product.title,
                    "image": (r.product.images[0].filename if r.product.images else None),
                },
            }
            for r in items
        ]
    )
