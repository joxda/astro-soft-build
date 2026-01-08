import datetime
import os
import subprocess

import jwt
import pam
import requests
from flask import Flask, make_response, redirect, render_template_string, request


def change_password(username, new_password):
    process = subprocess.Popen(
        ["passwd", username],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    process.communicate(f"{new_password}\n{new_password}\n")


# ================= CONFIG =================

DEFAULT_USERNAME = "tahti"
DEFAULT_PASSWORD = "tahti"

SECRET_KEY = os.urandom(32).hex()

app = Flask(__name__)
revoked_tokens = set()

# ================= HTML =================

LOGIN_FORM = """
<!DOCTYPE html>
<html>
<head><title>Login</title></head>
<body>
<h2>Login</h2>
{{ text|safe }}
<form method="POST">
<label>Username:</label><br>
<input type="text" name="username" required><br><br>
<label>Password:</label><br>
<input type="password" name="password" required><br><br>
<button type="submit">Login</button>
</form>
</body>
</html>
"""

FORCE_CHANGE_FORM = """
<!DOCTYPE html>
<html>
<head>
<title>Change Password</title>
<script>
async function loadHints() {
    try {
        const r = await fetch("/pam-hints/");
        const t = await r.text();
        document.getElementById("hints").innerText = t;
    } catch (e) {
        document.getElementById("hints").innerText =
            "Password must meet system security requirements.";
    }
}
window.onload = loadHints;
</script>
</head>
<body>
<h2>Change Default Password</h2>
<p>You must change the default password before continuing.</p>

<div id="hints" style="margin-bottom:10px;color:#555"></div>
{{ text|safe }}

<form method="POST">
<label>Current Password:</label><br>
<input type="password" name="current" required><br><br>

<label>New Password:</label><br>
<input type="password" name="new1" required><br><br>

<label>Confirm New Password:</label><br>
<input type="password" name="new2" required><br><br>

<button type="submit">Change Password</button>
</form>
</body>
</html>
"""

# ================= HELPERS =================


def generate_jwt(username):
    exp = datetime.datetime.utcnow() + datetime.timedelta(hours=9)
    return jwt.encode({"username": username, "exp": exp}, SECRET_KEY, algorithm="HS256")


def pam_error(p, fallback="Operation failed"):
    return p.reason if getattr(p, "reason", None) else fallback


def default_password_still_valid(username):
    if username != DEFAULT_USERNAME:
        return False
    p = pam.pam()
    return p.authenticate(username, DEFAULT_PASSWORD)


# ================= ROUTES =================


@app.route("/auth/", methods=["GET", "POST"])
def authenticate():
    if request.method == "GET":
        return render_template_string(LOGIN_FORM, text=request.args.get("t", ""))

    username = request.form.get("username")
    password = request.form.get("password")
    next_url = request.args.get("next", "/")

    p = pam.pam()
    if not p.authenticate(username, password):
        msg = pam_error(p, "Login failed")
        return render_template_string(
            LOGIN_FORM, text=f"<p style='color:red'>{msg}</p>"
        )

    token = generate_jwt(username)

    if username == DEFAULT_USERNAME and password == DEFAULT_PASSWORD:
        response = make_response(redirect("/force-change/"))
    else:
        response = make_response(redirect(next_url))

    response.set_cookie("jwt", token, httponly=True, secure=True)
    return response


@app.route("/force-change/", methods=["GET", "POST"])
def force_change():
    token = request.cookies.get("jwt")
    if not token:
        return redirect("/auth/")

    try:
        decoded = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        username = decoded["username"]
    except jwt.InvalidTokenError:
        return redirect("/auth/")

    text = ""

    if request.method == "POST":
        current = request.form.get("current")
        new1 = request.form.get("new1")
        new2 = request.form.get("new2")

        if new1 != new2:
            text = "<p style='color:red'>Passwords do not match</p>"
        else:
            p = pam.pam()
            if not p.authenticate(username, current):
                text = f"<p style='color:red'>{pam_error(p, 'Current password incorrect')}</p>"
            else:
                try:
                    change_password(username, new1)

                    # 🔐 expire session + force re-login
                    revoked_tokens.add(token)
                    response = make_response(
                        redirect("/auth/?t=Password%20changed.%20Please%20log%20in")
                    )
                    response.set_cookie(
                        "jwt", "", expires=0, httponly=True, secure=True
                    )
                    return response

                except Exception:
                    text = (
                        f"<p style='color:red'>{pam_error(p, 'Password rejected')}</p>"
                    )

    return render_template_string(FORCE_CHANGE_FORM, text=text)


@app.route("/pam-hints/", methods=["GET"])
def pam_hints():
    """
    Safely extract PAM password policy hints by triggering
    a guaranteed failure and reading p.reason.
    """
    p = pam.pam()
    try:
        p.chauthtok("invalid", "invalid")
    except Exception:
        pass

    hint = (
        p.reason
        if getattr(p, "reason", None)
        else "Password must meet system security requirements"
    )
    return hint, 200


@app.route("/validate/", methods=["GET"])
def validate():
    token = request.cookies.get("jwt")
    if not token or token in revoked_tokens:
        return "Unauthorized", 401

    try:
        decoded = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        username = decoded["username"]

        if default_password_still_valid(username):
            return "Password change required", 403

        return "OK", 200

    except jwt.ExpiredSignatureError:
        return "Token expired", 401
    except jwt.InvalidTokenError:
        return "Invalid token", 401


@app.route("/logout/")
def logout():
    token = request.cookies.get("jwt")
    if token:
        revoked_tokens.add(token)

    response = make_response(redirect("/auth/?t=Logged%20out"))
    response.set_cookie("jwt", "", expires=0, httponly=True, secure=True)
    return response


# ================= PROXY =================


def fetch_secure_content(path):
    backend_url = f"http://localhost:8080{path}"
    token = request.cookies.get("jwt")

    if not token or token in revoked_tokens:
        return "Unauthorized", 401

    headers = {"Authorization": f"Bearer {token}"}
    try:
        r = requests.get(backend_url, headers=headers)
        return r.text if r.status_code == 200 else ("Unauthorized", 401)
    except requests.RequestException:
        return "Backend error", 500


CHANGE_FORM = """
<!DOCTYPE html>
<html>
<head><title>Change Password</title></head>
<body>
<h2>Password change required</h2>
<form method="POST">
<label>Old Password:</label>
<input type="password" name="old_password" required><br><br>

<label>New Password:</label>
<input type="password" name="new_password" required><br><br>
<label>Repeat:</label>
<input type="password" name="new_password2" required><br><br>

<button type="submit">Change</button>
</form>
</body>
</html>
"""


@app.route("/change_password/", methods=["GET", "POST"])
def change_password():
    username = request.args.get("user")

    if request.method == "GET":
        return CHANGE_FORM

    old = request.form["old_password"]
    new = request.form["new_password"]
    new2 = request.form["new_password2"]

    if new == new2:
        p = pam.pam()
        # Try to change password
        result = p.chauthtok(username, old, new)

        if result:
            return redirect("/?t=Password changed successfully")
        else:
            return redirect("/change_password/?user=" + username + "&t=Failed")
    else:
        return redirect(
            "/change_password/?user=" + username + "&t=Passwords did not match"
        )


@app.route("/secure/<path:subpath>")
def secure(subpath):
    return fetch_secure_content(f"/{subpath}")


# ================= MAIN =================

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=9000)
