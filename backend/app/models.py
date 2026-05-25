from datetime import datetime, date
from sqlalchemy import func, UniqueConstraint
from .extensions import db, bcrypt


ROLE_USER = "user"
ROLE_ADMIN = "admin"
ROLES = (ROLE_USER, ROLE_ADMIN)

PAY_CASH = "cash"
PAY_CARD = "card"
PAY_METHODS = (PAY_CASH, PAY_CARD)

ORDER_STATUSES = (
    "created",
    "assembling",
    "issued",
    "delivered",
    "canceled",
)
ORDER_STATUS_LABELS = {
    "created": "Создан",
    "assembling": "В сборке",
    "issued": "Выдан",
    "delivered": "Доставлен",
    "canceled": "Отменен",
}


class User(db.Model):
    __tablename__ = "user"

    id = db.Column(db.Integer, primary_key=True)
    full_name = db.Column(db.String(255), nullable=False)
    login = db.Column(db.String(255), nullable=False, unique=True, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    phone = db.Column(db.String(50), nullable=False)
    birthday = db.Column(db.Date, nullable=False)
    role = db.Column(db.String(16), nullable=False, default=ROLE_USER)
    created_at = db.Column(db.DateTime, server_default=func.now(), nullable=False)

    cart_items = db.relationship("CartItem", backref="user", cascade="all, delete-orphan")
    favorites = db.relationship("Favorite", backref="user", cascade="all, delete-orphan")
    ratings = db.relationship("Rating", backref="user", cascade="all, delete-orphan")
    orders = db.relationship("Order", backref="user")

    def set_password(self, password):
        self.password_hash = bcrypt.generate_password_hash(password).decode("utf-8")

    def check_password(self, password):
        return bcrypt.check_password_hash(self.password_hash, password)

    @property
    def is_admin(self):
        return self.role == ROLE_ADMIN


class Category(db.Model):
    __tablename__ = "category"

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    slug = db.Column(db.String(255), nullable=False, unique=True, index=True)

    products = db.relationship("Product", backref="category")


class ProductType(db.Model):
    __tablename__ = "product_type"

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)

    products = db.relationship("Product", backref="product_type")


class Product(db.Model):
    __tablename__ = "product"

    id = db.Column(db.Integer, primary_key=True)
    category_id = db.Column(db.Integer, db.ForeignKey("category.id"), nullable=False, index=True)
    product_type_id = db.Column(db.Integer, db.ForeignKey("product_type.id"), nullable=False, index=True)
    title = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text, nullable=False, default="")
    price = db.Column(db.Numeric(10, 2), nullable=False, default=0)
    stock = db.Column(db.Integer, nullable=False, default=0)
    created_at = db.Column(db.DateTime, server_default=func.now(), nullable=False)

    images = db.relationship(
        "Image",
        backref="product",
        cascade="all, delete-orphan",
        order_by="Image.sort_order",
    )
    ratings = db.relationship("Rating", backref="product", cascade="all, delete-orphan")

    @property
    def average_rating(self):
        visible = [r for r in self.reviews if not r.is_hidden]
        if not visible:
            return 0.0
        return round(sum(r.stars for r in visible) / len(visible), 1)

    @property
    def in_stock(self):
        return self.stock > 0


class Image(db.Model):
    __tablename__ = "image"

    id = db.Column(db.Integer, primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey("product.id"), nullable=False, index=True)
    filename = db.Column(db.String(255), nullable=False)
    sort_order = db.Column(db.Integer, nullable=False, default=0)


class Review(db.Model):
    __tablename__ = "review"
    __table_args__ = (
        UniqueConstraint("user_id", "product_id", name="uq_review_user_product"),
    )

    id = db.Column(db.Integer, primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey("product.id"), nullable=False, index=True)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=True, index=True)
    author_name = db.Column(db.String(255), nullable=False)
    stars = db.Column(db.Integer, nullable=False)
    text = db.Column(db.Text, nullable=False, default="")
    is_hidden = db.Column(db.Boolean, nullable=False, default=False)
    is_promoted = db.Column(db.Boolean, nullable=False, default=False)
    created_at = db.Column(db.DateTime, server_default=func.now(), nullable=False)

    product = db.relationship("Product", backref=db.backref("reviews", cascade="all, delete-orphan"))
    user = db.relationship("User")


class Rating(db.Model):
    __tablename__ = "rating"
    __table_args__ = (UniqueConstraint("user_id", "product_id", name="uq_rating_user_product"),)

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False, index=True)
    product_id = db.Column(db.Integer, db.ForeignKey("product.id"), nullable=False, index=True)
    stars = db.Column(db.Integer, nullable=False)
    created_at = db.Column(db.DateTime, server_default=func.now(), nullable=False)


class Favorite(db.Model):
    __tablename__ = "favorite"
    __table_args__ = (UniqueConstraint("user_id", "product_id", name="uq_favorite_user_product"),)

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False, index=True)
    product_id = db.Column(db.Integer, db.ForeignKey("product.id"), nullable=False, index=True)
    created_at = db.Column(db.DateTime, server_default=func.now(), nullable=False)

    product = db.relationship("Product")


class CartItem(db.Model):
    __tablename__ = "cart_item"
    __table_args__ = (UniqueConstraint("user_id", "product_id", name="uq_cart_user_product"),)

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False, index=True)
    product_id = db.Column(db.Integer, db.ForeignKey("product.id"), nullable=False, index=True)
    quantity = db.Column(db.Integer, nullable=False, default=1)

    product = db.relationship("Product")


class Order(db.Model):
    __tablename__ = "order"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("user.id"), nullable=False, index=True)
    total = db.Column(db.Numeric(10, 2), nullable=False, default=0)
    address = db.Column(db.String(500), nullable=False)
    pay_method = db.Column(db.String(16), nullable=False)
    status = db.Column(db.String(32), nullable=False, default="created")
    delivery_date = db.Column(db.Date, nullable=False)
    delivery_time = db.Column(db.String(5), nullable=False)
    customer_comment = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, server_default=func.now(), nullable=False)

    items = db.relationship(
        "OrderItem", backref="order", cascade="all, delete-orphan"
    )


class OrderItem(db.Model):
    __tablename__ = "order_item"

    id = db.Column(db.Integer, primary_key=True)
    order_id = db.Column(db.Integer, db.ForeignKey("order.id"), nullable=False, index=True)
    product_id = db.Column(db.Integer, db.ForeignKey("product.id"), nullable=True)
    title_snapshot = db.Column(db.String(255), nullable=False)
    price_snapshot = db.Column(db.Numeric(10, 2), nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
