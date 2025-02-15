#!/usr/bin/env python

import gps
import subprocess
import time
import os
import signal

# Command to start gpsfake with system time (-T) and continuous mode
VIRTUAL_GPS_CMD = "gpsfake -T /usr/local/share/nmea_fake"

# Start virtual GPS
virtual_proc = subprocess.Popen(VIRTUAL_GPS_CMD, shell=True, preexec_fn=os.setsid)

# Connect to gpsd
session = gps.gps(mode=gps.WATCH_ENABLE)

print("Waiting for real GPS fix...")

try:
    while True:
        report = session.next()

        # Ensure it's a TPV report
        if report['class'] == 'TPV':
            real_fix = False

            # Check if the device is NOT the fake one
            if hasattr(report, 'device') and "/dev/" in report.device:
                # Check for real satellite data
                if hasattr(report, 'mode') and report.mode >= 2:  # 2D or 3D Fix
                    if hasattr(report, 'used') and report.used > 0:  # Satellites used in fix
                        real_fix = True

            if real_fix:
                print(f"Real GPS fix acquired from {report.device} (mode={report.mode}). Stopping virtual GPS.")

                # Stop the virtual GPS process
                os.killpg(os.getpgid(virtual_proc.pid), signal.SIGTERM)
                break

        time.sleep(1)

except KeyboardInterrupt:
    print("Interrupted. Cleaning up...")
    os.killpg(os.getpgid(virtual_proc.pid), signal.SIGTERM)
    os._exit(0)
