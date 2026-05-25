from sqlalchemy import inspect, text

from .extensions import db


def _column_exists(inspector, table, column):
    return any(c["name"] == column for c in inspector.get_columns(table))


def _add_column(inspector, table, column, ddl):
    if not inspector.has_table(table):
        return
    if _column_exists(inspector, table, column):
        return
    db.session.execute(text(f'ALTER TABLE "{table}" ADD COLUMN {ddl}'))


def _index_exists(inspector, table, name):
    if not inspector.has_table(table):
        return False
    return any(idx["name"] == name for idx in inspector.get_indexes(table))


def auto_migrate():
    inspector = inspect(db.engine)

    _add_column(inspector, "order", "customer_comment", "customer_comment TEXT")

    if inspector.has_table("review") and not _index_exists(
        inspector, "review", "uq_review_user_product"
    ):
        db.session.execute(
            text(
                "CREATE UNIQUE INDEX uq_review_user_product "
                "ON review (user_id, product_id) "
                "WHERE user_id IS NOT NULL"
            )
        )

    db.session.commit()
