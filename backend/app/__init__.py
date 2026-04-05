import os
from flask import Flask, send_from_directory, jsonify

from config import Config
from .extensions import db, migrate, jwt, cors, bcrypt


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)

    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    bcrypt.init_app(app)
    cors.init_app(
        app,
        resources={r"/api/*": {"origins": app.config["CORS_ORIGINS"]}},
        supports_credentials=True,
    )

    from . import models  # noqa: F401
    from .cli import register_cli

    register_cli(app)

    from .routes.auth import bp as auth_bp
    from .routes.catalog import bp as catalog_bp
    from .routes.cart import bp as cart_bp
    from .routes.favorites import bp as favorites_bp
    from .routes.ratings import bp as ratings_bp
    from .routes.orders import bp as orders_bp
    from .routes.admin import bp as admin_bp

    app.register_blueprint(auth_bp, url_prefix="/api/auth")
    app.register_blueprint(catalog_bp, url_prefix="/api")
    app.register_blueprint(cart_bp, url_prefix="/api/cart")
    app.register_blueprint(favorites_bp, url_prefix="/api/favorites")
    app.register_blueprint(ratings_bp, url_prefix="/api")
    app.register_blueprint(orders_bp, url_prefix="/api/orders")
    app.register_blueprint(admin_bp, url_prefix="/api/admin")

    @app.route("/api/health")
    def health():
        return jsonify(status="ok")

    @app.route("/uploads/products/<path:filename>")
    def serve_upload(filename):
        return send_from_directory(app.config["UPLOAD_FOLDER"], filename)

    return app
