# -*- coding: utf-8 -*-
"""Public section, including homepage and signup."""
from flask import (
    Blueprint,
    current_app,
    flash,
    redirect,
    render_template,
    request,
    url_for,
    jsonify
)
from flask_login import login_required, login_user, logout_user

from online_compiler.extensions import login_manager
from online_compiler.public.forms import LoginForm
from online_compiler.user.forms import RegisterForm
from online_compiler.user.models import User
from online_compiler.utils import flash_errors

import requests

blueprint = Blueprint("public", __name__, static_folder="../static")



@login_manager.user_loader
def load_user(user_id):
    """Load user by ID."""
    return User.get_by_id(int(user_id))


# @blueprint.route("/", methods=["GET", "POST"])
# def home():
#     """Home page."""
#     form = LoginForm(request.form)
#     current_app.logger.info("Hello from the home page!")
#     # Handle logging in
#     if request.method == "POST":
#         if form.validate_on_submit():
#             login_user(form.user)
#             flash("You are logged in.", "success")
#             redirect_url = request.args.get("next") or url_for("user.members")
#             return redirect(redirect_url)
#         else:
#             flash_errors(form)
#     return render_template("public/home.html", form=form)

JUDGE0_URL = "http://judge0-server:2358/submissions/"
HEADERS = {"Content-Type": "application/json"}

# List of supported languages (partial example)
LANGUAGES = [
    {"id": 54, "name": "C++ (GCC 9.2.0)"},
    {"id": 62, "name": "Java (OpenJDK 13.0.1)"},
    {"id": 71, "name": "Python (3.8.1)"},
    {"id": 63, "name": "JavaScript (Node.js 12.14.0)"},
]

@blueprint.route("/", methods=["GET", "POST"])
def home():
    output = None
    error = None
    code = ""
    language_id = None

    form = LoginForm(request.form)
    current_app.logger.info("Hello from the home page!")

    current_app.logger.info(request.method)
    if request.method == "POST":
        if form.validate_on_submit():
            login_user(form.user)
            flash("You are logged in.", "success")
            redirect_url = request.args.get("next") or url_for("user.members")
            return redirect(redirect_url)

        code = request.form.get("code")
        language_id = request.form.get("language")
        csrf_token = request.form.get("csrf_token")

        if not code or not language_id:
            error = "Please provide both code and a programming language."
        else:
            payload = {
                "source_code": code,
                "language_id": int(language_id),
                "stdin": "",
                "csrf_token": csrf_token
            }
            try:
                submission = requests.post(JUDGE0_URL, headers=HEADERS, json=payload)
                submission.raise_for_status()
                token = submission.json().get("token")
                result = requests.get(f"{JUDGE0_URL}{token}", headers=HEADERS)
                result.raise_for_status()
                output = result.json().get("stdout", "No output received.")
                current_app.logger.error(result.json())
            except requests.exceptions.RequestException as e:
                error = f"An error occurred: {e}"

    return render_template(
        "public/home.html",
        form=form,
        languages=LANGUAGES,
        output=output,
        error=error,
        code=code,
        selected_language=language_id,
    )




@blueprint.route("/logout/")
@login_required
def logout():
    """Logout."""
    logout_user()
    flash("You are logged out.", "info")
    return redirect(url_for("public.home"))


@blueprint.route("/register/", methods=["GET", "POST"])
def register():
    """Register new user."""
    form = RegisterForm(request.form)
    if form.validate_on_submit():
        User.create(
            username=form.username.data,
            email=form.email.data,
            password=form.password.data,
            active=True,
        )
        flash("Thank you for registering. You can now log in.", "success")
        return redirect(url_for("public.home"))
    else:
        flash_errors(form)
    return render_template("public/register.html", form=form)


@blueprint.route("/about/")
def about():
    """About page."""
    form = LoginForm(request.form)
    return render_template("public/about.html", form=form)
