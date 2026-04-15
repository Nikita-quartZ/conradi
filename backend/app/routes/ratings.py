from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from marshmallow import ValidationError

from ..extensions import db
from ..models import Product, Rating
from ..schemas import RatingIn

bp = Blueprint("ratings", __name__)
rating_in = RatingIn()


@bp.post("/products/<int:product_id>/rating")
@jwt_required()
def set_rating(product_id):
    if not db.session.get(Product, product_id):
        return jsonify(error="Товар не найден"), 404

    try:
        data = rating_in.load(request.get_json() or {})
    except ValidationError as err:
        return jsonify(errors=err.messages), 400

    user_id = int(get_jwt_identity())
    existing = Rating.query.filter_by(user_id=user_id, product_id=product_id).first()
    if existing:
        existing.stars = data["stars"]
    else:
        db.session.add(
            Rating(user_id=user_id, product_id=product_id, stars=data["stars"])
        )
    db.session.commit()

    product = db.session.get(Product, product_id)
    return jsonify(
        average_rating=product.average_rating,
        my_stars=data["stars"],
        ratings_count=len(product.ratings),
    )


@bp.get("/products/<int:product_id>/rating/mine")
@jwt_required()
def my_rating(product_id):
    user_id = int(get_jwt_identity())
    rating = Rating.query.filter_by(user_id=user_id, product_id=product_id).first()
    return jsonify(stars=rating.stars if rating else None)
