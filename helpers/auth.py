from flask import Flask, redirect, request, jsonify, make_response, render_template_string
import pam
import base64
import datetime
import os
import requests
import jwt

SECRET_KEY = os.urandom(32).hex()

app = Flask(__name__)

revoked_tokens = set()

LOGIN_FORM = """
<!DOCTYPE html>
<html>
<head>
<title>Login</title>
</head>
<body>
<h2>Login</h2>
{{ text }}
<form method="POST">
<label>Username:</label>
<input type="text" name="username" required><br><br>
<label>Password:</label>
<input type="password" name="password" required><br><br>
<button type"submit">Login</button>
</form>
</body>
</html>
"""

def generate_jwt(username):
   expiration = datetime.datetime.utcnow() + datetime.timedelta(hours=9)
   token = jwt.encode({"username": username, "exp": expiration}, SECRET_KEY, algorithm="HS256")
   return token

@app.route("/auth/", methods=["GET", "POST"])
def authenticate():
   if request.method == "GET":
      text = request.args.get('t','')      
      return render_template_string(LOGIN_FORM, text=text)
   username = request.form.get("username")
   password = request.form.get("password")
   next_url = request.args.get('next','/')
   p = pam.pam()
   if p.authenticate(username, password):
       token = generate_jwt(username)
       response = make_response(redirect(next_url))
       response.set_cookie("jwt", token, httponly=True, secure=True)  # Store JWT in a cookie
       return response
   return redirect("/login?t=Login%20failed")

@app.route("/validate/", methods=["GET"])
def validate():
   token = request.cookies.get("jwt")  # Read JWT from cookie
   if not token or token in revoked_tokens:
      return "Unauthorized", 401

   try:
       decoded = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
       return "OK", 200 #jsonify({"username": decoded["username"]}), 200
   except jwt.ExpiredSignatureError:
      return "Token expired", 401
   except jwt.InvalidTokenError:
      return "Invalid token", 401

@app.route("/logout/", methods=["GET","POST"])
def logout():
   token = request.cookies.get("jwt")
   if token:
       revoked_tokens.add(token)  # Add token to blocklist
   response = make_response(redirect("/login?t=Logged%20out"))
   response.set_cookie("jwt", "", expires=0, httponly=True, secure=True)  # Clear cookie
   return response

# Function to fetch and embed content
def fetch_secure_content(path):
   backend_url = f"http://localhost:8080{path}"  # NGINX proxy backend
   token = request.cookies.get("jwt")

   if not token or token in revoked_tokens:
       return "Unauthorized", 401

   headers = {"Authorization": f"Bearer {token}"}
   try:
       response = requests.get(backend_url, headers=headers)
       if response.status_code == 200:
           return response.text
       else:
           return "Unauthorized", 401
   except requests.RequestException:
       return "Error fetching content", 500

# Secure1 Wrapped with Header
@app.route("/secure/<path:subpath>")
def secure(subpath):
   return fetch_secure_content(f"/{subpath}")
   

if __name__ == '__main__':
   app.run(host='127.0.0.1', port=9000)
