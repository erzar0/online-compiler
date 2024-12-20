# -*- coding: utf-8 -*-
"""Public section, including homepage and signup."""
from flask import (
    Blueprint,
    current_app,
    flash,
    redirect,
    render_template,
    request,
    url_for
)
from flask_login import login_required, login_user, logout_user

from online_compiler.extensions import login_manager
from online_compiler.public.forms import LoginForm
from online_compiler.user.forms import RegisterForm
from online_compiler.user.models import User
from online_compiler.utils import flash_errors
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST


import requests
import base64

blueprint = Blueprint("public", __name__, static_folder="../static")

@login_manager.user_loader
def load_user(user_id):
    """Load user by ID."""
    return User.get_by_id(int(user_id))

JUDGE0_URL = "http://judge0-server:2358/submissions/"
HEADERS = {"Content-Type": "application/json"}
LANGUAGES = [{"id":45,"name":"Assembly (NASM 2.14.02)"},{"id":46,"name":"Bash (5.0.0)"},{"id":47,"name":"Basic (FBC 1.07.1)"},{"id":75,"name":"C (Clang 7.0.1)"},{"id":76,"name":"C++ (Clang 7.0.1)"},{"id":48,"name":"C (GCC 7.4.0)"},{"id":52,"name":"C++ (GCC 7.4.0)"},{"id":49,"name":"C (GCC 8.3.0)"},{"id":53,"name":"C++ (GCC 8.3.0)"},{"id":50,"name":"C (GCC 9.2.0)"},{"id":54,"name":"C++ (GCC 9.2.0)"},{"id":86,"name":"Clojure (1.10.1)"},{"id":51,"name":"C# (Mono 6.6.0.161)"},{"id":77,"name":"COBOL (GnuCOBOL 2.2)"},{"id":55,"name":"Common Lisp (SBCL 2.0.0)"},{"id":56,"name":"D (DMD 2.089.1)"},{"id":57,"name":"Elixir (1.9.4)"},{"id":58,"name":"Erlang (OTP 22.2)"},{"id":44,"name":"Executable"},{"id":87,"name":"F# (.NET Core SDK 3.1.202)"},{"id":59,"name":"Fortran (GFortran 9.2.0)"},{"id":60,"name":"Go (1.13.5)"},{"id":88,"name":"Groovy (3.0.3)"},{"id":61,"name":"Haskell (GHC 8.8.1)"},{"id":62,"name":"Java (OpenJDK 13.0.1)"},{"id":63,"name":"JavaScript (Node.js 12.14.0)"},{"id":78,"name":"Kotlin (1.3.70)"},{"id":64,"name":"Lua (5.3.5)"},{"id":89,"name":"Multi-file program"},{"id":79,"name":"Objective-C (Clang 7.0.1)"},{"id":65,"name":"OCaml (4.09.0)"},{"id":66,"name":"Octave (5.1.0)"},{"id":67,"name":"Pascal (FPC 3.0.4)"},{"id":85,"name":"Perl (5.28.1)"},{"id":68,"name":"PHP (7.4.1)"},{"id":43,"name":"Plain Text"},{"id":69,"name":"Prolog (GNU Prolog 1.4.5)"},{"id":70,"name":"Python (2.7.17)"},{"id":71,"name":"Python (3.8.1)"},{"id":80,"name":"R (4.0.0)"},{"id":72,"name":"Ruby (2.7.0)"},{"id":73,"name":"Rust (1.40.0)"},{"id":81,"name":"Scala (2.13.2)"},{"id":82,"name":"SQL (SQLite 3.27.2)"},{"id":83,"name":"Swift (5.2.3)"},{"id":74,"name":"TypeScript (3.7.4)"},{"id":84,"name":"Visual Basic.Net (vbnc 0.0.0.5943)"}]

REQUEST_COUNT = Counter("http_requests_total", "Total HTTP Requests", ["method", "endpoint"])
CODE_SUBMISSIONS = Counter("code_submissions_total", "Total Code Submissions", ["language"])

@login_manager.user_loader
def load_user(user_id):
    """Load user by ID."""
    return User.get_by_id(int(user_id))


@blueprint.route("/metrics")
def metrics():
    """Expose Prometheus metrics."""
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


@blueprint.route("/", methods=["GET", "POST"])
def home():
    REQUEST_COUNT.labels(method=request.method, endpoint="/").inc()

    result_data = None
    error = None
    code = ""
    language_id = None

    form = LoginForm(request.form)
    current_app.logger.info("Hello from the home page!")

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
                submission = requests.post(f"{JUDGE0_URL}?wait=true", headers=HEADERS, json=payload)
                submission.raise_for_status()
                CODE_SUBMISSIONS.labels(language=language_id).inc()

                token = submission.json().get("token")

                result = requests.get(f"{JUDGE0_URL}{token}?base64_encoded=true", headers=HEADERS)
                result.raise_for_status()
                result_data = result.json()
                current_app.logger.error(result_data)

                for field in ["stdout", "compile_output", "stderr", "message"]:
                    if result_data[field] is not None:
                        result_data[field] = base64.b64decode(result_data[field]).decode("utf-8", errors="ignore")

            except requests.exceptions.RequestException as e:
                error = f"An error occurred: {e}"

    return render_template(
        "public/home.html",
        form=form,
        languages=LANGUAGES,
        result=result_data,
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
