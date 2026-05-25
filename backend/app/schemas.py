from marshmallow import Schema, fields, validate, validates_schema, ValidationError

from .models import ROLES, PAY_METHODS, ORDER_STATUSES


class RegisterSchema(Schema):
    full_name = fields.Str(required=True, validate=validate.Length(min=2, max=255))
    login = fields.Str(required=True, validate=validate.Length(min=3, max=255))
    password = fields.Str(required=True, validate=validate.Length(min=6, max=128))
    phone = fields.Str(required=True, validate=validate.Length(min=5, max=50))
    birthday = fields.Date(required=True)


class LoginSchema(Schema):
    login = fields.Str(required=True)
    password = fields.Str(required=True)


class UserOut(Schema):
    id = fields.Int()
    full_name = fields.Str()
    login = fields.Str()
    phone = fields.Str()
    birthday = fields.Date()
    role = fields.Str()
    created_at = fields.DateTime()


class UserUpdate(Schema):
    full_name = fields.Str(validate=validate.Length(min=2, max=255))
    phone = fields.Str(validate=validate.Length(min=5, max=50))
    birthday = fields.Date()


class CategoryOut(Schema):
    id = fields.Int()
    title = fields.Str()
    slug = fields.Str()


class ProductTypeOut(Schema):
    id = fields.Int()
    title = fields.Str()


class ImageOut(Schema):
    id = fields.Int()
    filename = fields.Str()
    sort_order = fields.Int()
    url = fields.Method("get_url")

    def get_url(self, obj):
        return f"/uploads/products/{obj.filename}"


class ProductOut(Schema):
    id = fields.Int()
    title = fields.Str()
    description = fields.Str()
    price = fields.Float()
    stock = fields.Int()
    in_stock = fields.Bool()
    average_rating = fields.Float()
    category = fields.Nested(CategoryOut)
    product_type = fields.Nested(ProductTypeOut)
    images = fields.Nested(ImageOut, many=True)


class ProductShort(Schema):
    id = fields.Int()
    title = fields.Str()
    price = fields.Float()
    stock = fields.Int()
    in_stock = fields.Bool()
    images = fields.Nested(ImageOut, many=True)


class CartItemOut(Schema):
    id = fields.Int()
    quantity = fields.Int()
    product = fields.Nested(ProductShort)


class FavoriteOut(Schema):
    id = fields.Int()
    product = fields.Nested(ProductShort)


class OrderItemOut(Schema):
    id = fields.Int()
    product_id = fields.Int(allow_none=True)
    title_snapshot = fields.Str()
    price_snapshot = fields.Float()
    quantity = fields.Int()


class OrderOut(Schema):
    id = fields.Int()
    total = fields.Float()
    address = fields.Str()
    pay_method = fields.Str()
    status = fields.Str()
    status_label = fields.Method("get_status_label")
    delivery_date = fields.Date()
    delivery_time = fields.Str()
    customer_comment = fields.Str(allow_none=True)
    created_at = fields.DateTime()
    items = fields.Nested(OrderItemOut, many=True)

    def get_status_label(self, obj):
        from .models import ORDER_STATUS_LABELS

        return ORDER_STATUS_LABELS.get(obj.status, obj.status)


class CheckoutSchema(Schema):
    address = fields.Str(required=True, validate=validate.Length(min=5, max=500))
    pay_method = fields.Str(required=True, validate=validate.OneOf(PAY_METHODS))
    delivery_date = fields.Date(required=True)
    delivery_time = fields.Str(
        required=True,
        validate=validate.Regexp(r"^([01]\d|2[0-3]):[0-5]\d$"),
    )
    customer_comment = fields.Str(
        load_default=None, allow_none=True, validate=validate.Length(max=1000)
    )
    card_number = fields.Str(load_default=None)
    card_holder = fields.Str(load_default=None)
    card_expiry = fields.Str(load_default=None)
    card_cvv = fields.Str(load_default=None)


class AdminStatusUpdate(Schema):
    status = fields.Str(required=True, validate=validate.OneOf(ORDER_STATUSES))


class AdminRoleUpdate(Schema):
    role = fields.Str(required=True, validate=validate.OneOf(ROLES))


class CategoryIn(Schema):
    title = fields.Str(required=True, validate=validate.Length(min=1, max=255))
    slug = fields.Str(required=True, validate=validate.Length(min=1, max=255))


class ProductTypeIn(Schema):
    title = fields.Str(required=True, validate=validate.Length(min=1, max=255))


class ProductIn(Schema):
    category_id = fields.Int(required=True)
    product_type_id = fields.Int(required=True)
    title = fields.Str(required=True, validate=validate.Length(min=1, max=255))
    description = fields.Str(load_default="")
    price = fields.Decimal(required=True, as_string=False)
    stock = fields.Int(required=True, validate=validate.Range(min=0))


class RatingIn(Schema):
    stars = fields.Int(required=True, validate=validate.Range(min=1, max=5))


class ReviewOut(Schema):
    id = fields.Int()
    product_id = fields.Int()
    author_name = fields.Str()
    stars = fields.Int()
    text = fields.Str()
    is_hidden = fields.Bool()
    is_promoted = fields.Bool()
    created_at = fields.DateTime()


class ReviewIn(Schema):
    stars = fields.Int(required=True, validate=validate.Range(min=1, max=5))
    text = fields.Str(required=True, validate=validate.Length(min=3, max=2000))


class AdminReviewIn(Schema):
    product_id = fields.Int(required=True)
    author_name = fields.Str(required=True, validate=validate.Length(min=2, max=255))
    stars = fields.Int(required=True, validate=validate.Range(min=1, max=5))
    text = fields.Str(required=True, validate=validate.Length(min=3, max=2000))
    is_promoted = fields.Bool(load_default=True)


class AdminReviewPatch(Schema):
    is_hidden = fields.Bool()
    is_promoted = fields.Bool()
