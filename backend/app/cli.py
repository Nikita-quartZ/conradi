import click
from datetime import date
from flask.cli import with_appcontext

from .extensions import db
from .models import User, ROLE_ADMIN


@click.command("create-admin")
@click.argument("login")
@click.argument("password")
@click.option("--name", default="Администратор")
@click.option("--phone", default="+70000000000")
@with_appcontext
def create_admin(login, password, name, phone):
    if User.query.filter_by(login=login).first():
        click.echo(f"Пользователь с логином {login} уже существует")
        return

    user = User(
        full_name=name,
        login=login,
        phone=phone,
        birthday=date(1990, 1, 1),
        role=ROLE_ADMIN,
    )
    user.set_password(password)
    db.session.add(user)
    db.session.commit()
    click.echo(f"Админ {login} создан, id={user.id}")


def register_cli(app):
    app.cli.add_command(create_admin)
