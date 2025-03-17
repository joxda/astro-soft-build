from flask import Flask, jsonify
import PyIndi
import time

app = Flask(__name__)

class IndiClient(PyIndi.BaseClient):
   def __init__(self):
       super().__init__()

   def connect(self, server="localhost", port=8624):
       self.setServer(server, port)
       if not self.connectServer():
           print("Failed to connect to INDI server")
           return False
       time.sleep(2)
       for device_name in self.getDevices():
           device = self.get(device_name)
           if device:
               for prop in device.getPropertoes():
                   if "EQUATORIAL_EOD_COORD" in prop.name:
                       self.telescope_device = device_name
                       print(f"Using telescope: {self.telescope_device}")
                       return True
       print("No telescope found")
       return False

   def get_telescope_data(self):
       if not self.telescope_device:
           print("No telescope detected!")
           return None
       device = self.getDevice(self.telescope_device)
       if not device:
           return None

       eq_coords = device.getNumber("EQUATORIAL_EOD_COORD")
       if not eq_coords:
           return None

       ra = eq_coords[0].value  # RA in hours
       dec = eq_coords[1].value  # Dec in degrees
       return {"ra": ra, "dec": dec}

indiclient = IndiClient()
indiclient.setServer("localhost", 8624)
connected = indiclient.connect()

@app.route('/telescope-data', methods=['GET'])
def get_telescope_data():
   if not connected:
       connected = indiclient.connect()
       if not connected:
           return jsonify({"error": "No data"}), 500  
   data = indiclient.get_telescope_data()
   if data:
       return jsonify(data)
   return jsonify({"error": "No data"}), 500

if __name__ == '__main__':
   app.run(host='127.0.0.1', port=8627)