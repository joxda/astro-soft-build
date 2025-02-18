#!/usr/bin/env python

import time
import serial

# configure the serial connections (the parameters differs on the device you are connecting to)
ser = serial.Serial(port='/dev/OnStep', baudrate=9600)

ser.isOpen()

def serial_send(s):
  string = s.encode('utf-8')
  ser.write(string)
  time.sleep(0.05)

serial_send(':GVN#')
ser.close()