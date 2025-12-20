import time

import PyIndi
from flask import Flask, jsonify

app = Flask(__name__)


class IndiClient(PyIndi.BaseClient):
    def __init__(self):
        super().__init__()

    def connect(self, server="localhost", port=7624):
        self.setServer(server, port)
        if not self.connectServer():
            print("Failed to connect to INDI server")
            return False
        time.sleep(2)
        for device in self.getDevices():
            print(device)
            print(device.getDeviceName())
            if device:
                for prop in device.getProperties():
                    print(prop.getName())
                    if prop.getName() in ("EQUATORIAL_EOD_COORD", "EQUATORIAL_COORD", "EQUATORIAL_COORD_REQUEST"):
                        self.telescope_device = device
                        print(f"Using telescope: {self.telescope_device.getDeviceName()}")
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
indiclient.setServer("localhost", 7624)
connected = indiclient.connect()


@app.route("/telescope-data", methods=["GET"])
def get_telescope_data():
    global connected
    if not connected:
        connected = indiclient.connect()
        if not connected:
            return jsonify({"error": "No data"}), 500
    data = indiclient.get_telescope_data()
    if data:
        return jsonify(data)
    return jsonify({"error": "No data"}), 500


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8627)
