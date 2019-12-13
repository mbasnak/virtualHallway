import os
import sys
import time
sys.path.insert(0, os.path.abspath('C:/Users/Jenny/PycharmProjects/conditioned_menotaxis'))
from fictrac_2d import TriggerDevice

def arduinoPulse(value=None, timeOn=None, timeOff=None, pulseNumber=None):
    valueArduino = value or 0
    onPulse = timeOn or 1
    offPulse = timeOff or 1
    pulses = pulseNumber or 5
    client = TriggerDevice('/./COM20')
    for i in range(pulses):
        client.set_value(valueArduino)
        time.sleep(onPulse)
        client.set_value(0)
        time.sleep(offPulse)


if __name__ == '__main__':

    """
    ARGV: 
    1: value,
    2: time on,
    3: time off,
    4: pulse number,
    """

    if len(sys.argv) > 1:
        value = int(sys.argv[1])
        timeon = float(sys.argv[2])
        timeoff = float(sys.argv[3])
        pulsenumber = int(sys.argv[4])
        arduinoPulse(value, timeon, timeoff, pulsenumber)
    else:
        arduinoPulse()