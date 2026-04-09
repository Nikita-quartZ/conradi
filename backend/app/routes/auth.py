from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from marshmallow import ValidationError
from sqlalchemy.exc import IntegrityError

from ..extensions import db
from ..models import User
from ..schemas import RegisterSchema, LoginSchema, UserOut

bp = Blueprint("auth", __name__)

register_schema = RegisterSchema()
login_schema = LoginSchema()
user_out = UserOut()


def _token_for(user):
    return create_access_token(
        identity=str(user.id),
        additional_claims={"role": user.role},
    )


@bp.post("/register")
def register():
    try:
        data = register_schema.load(request.get_json() or {})
    except ValidationError as err:
        return jsonify(errors=err.messages), 400

    if User.query.filter_by(login=data["login"]).first():
        return jsonify(errors={"login": ["Логин уже занят"]}), 400

    user = User(
        full_name=data["full_name"],
        login=data["login"],
        phone=data["phone"],
        birthday=data["birthday"],
    )
    user.set_password(data["password"])

    db.session.add(user)
    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return jsonify(errors={"login": ["Логин уже занят"]}), 400

    return jsonify(token=_token_for(user), user=user_out.dump(user)), 201


@bp.post("/login")
def login():
    try:
        data = login_schema.load(request.get_json() or {})
    except ValidationError as err:
        return jsonify(errors=err.messages), 400

    user = User.query.filter_by(login=data["login"]).first()
    if not user or not user.check_password(data["password"]):
        return jsonify(error="Неверный логин или пароль"), 401

    return jsonify(token=_token_for(user), user=user_out.dump(user))


@bp.get("/me")
@jwt_required()
def me():
    user_id = get_jwt_identity()
    user = User.query.get(int(user_id))
    if not user:
        return jsonify(error="Пользователь не найден"), 404
    return jsonify(user=user_out.dump(user))
