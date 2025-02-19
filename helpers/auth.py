from flask import Flask, request, Response
import pam
import base64

app = Flask(__name__)

@app.route('/auth', methods=['GET'])
def auth():
   cert_status = request.headers.get("X-Cert-Status")
   if cert_status == "SUCCESS":
       return Response('OK', 200)
   auth_header = request.headers.get('Authorization')
   if not auth_header:
#      print("no header")
      return Response('Unauthorized', 401, {'WWW-Authenticate': 'Basic realm="Login"'})

   try:
       auth_type, credentials = auth_header.split()
       username, password = base64.b64decode(credentials).decode().split(':')
#       print(username, password)
       p = pam.pam()
       if p.authenticate(username, password):
#           print("OK")
           return Response('OK', 200)
   except Exception as e:
       print("Exception: ", e)
       pass
#   print("NOOO")
   return Response('Unauthorized', 401, {'WWW-Authenticate': 'Basic realm="Login"'})

if __name__ == '__main__':
   app.run(host='127.0.0.1', port=9000)#, ssl_context=('/etc/selfsigned/self.pem','/etc/selfsigned/key.pem'))
