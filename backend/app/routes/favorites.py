from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy.exc import IntegrityError

from ..extensions import db
from ..models import Favorite, Product
from ..schemas import FavoriteOut

bp = Blueprint("favorites", __name__)
favorite_out = FavoriteOut()


def _user_id():
    return int(get_jwt_identity())


@bp.get("")
@jwt_required()
def list_favorites():
    items = (
        Favorite.query.filter_by(user_id=_user_id())
        .order_by(Favorite.created_at.desc())
        .all()
    )
    return jsonify(items=[favorite_out.dump(f) for f in items])


@bp.post("")
@jwt_required()
def add_favorite():
    data = request.get_json() or {}
    product_id = data.get("product_id")
    if not product_id or not db.session.get(Product, product_id):
        return jsonify(error="Товар не найден"), 404

    uid = _user_id()
    existing = Favorite.query.filter_by(user_id=uid, product_id=product_id).first()
    if existing:
        return jsonify(item=favorite_out.dump(existing)), 200

    fav = Favorite(user_id=uid, product_id=product_id)
    db.session.add(fav)
    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        existing = Favorite.query.filter_by(user_id=uid, product_id=product_id).first()
        return jsonify(item=favorite_out.dump(existing)), 200
    return jsonify(item=favorite_out.dump(fav)), 201


@bp.delete("/<int:product_id>")
@jwt_required()
def remove_favorite(product_id):
    fav = Favorite.query.filter_by(user_id=_user_id(), product_id=product_id).first()
    if not fav:
        return jsonify(error="В избранном нет такого товара"), 404
    db.session.delete(fav)
    db.session.commit()
    return jsonify(ok=True)


@bp.get("/ids")
@jwt_required()
def favorite_ids():
    rows = (
        db.session.query(Favorite.product_id)
        .filter_by(user_id=_user_id())
        .all()
    )
    return jsonify(ids=[r[0] for r in rows])
