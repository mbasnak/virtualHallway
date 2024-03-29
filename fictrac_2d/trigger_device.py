from __future__ import print_function
import time
import serial


class TriggerDevice(serial.Serial):

    ResetSleepDt = 2.0
    Baudrate = 115200

    CmdSetTriggerLow = 'l'
    CmdSetTriggerHigh = 'h'

    def __init__(self, port, timeout=10.0):
        param = {'baudrate': self.Baudrate, 'timeout': timeout}
        super(TriggerDevice, self).__init__(port, **param)
        time.sleep(self.ResetSleepDt)
        self.is_high = None

    def set_low(self):
        if (self.is_high is None) or self.is_high:
            #self.write(str.encode(self.CmdSetTriggerLow))
            self.write(str.encode('[{0}]\n'.format(self.CmdSetTriggerLow)))
            self.is_high = False

    def set_high(self):
        if (self.is_high is None) or not self.is_high:
            self.write(str.encode('[{0}]\n'.format(self.CmdSetTriggerHigh)))
            self.is_high = True

    def set_value(self, value):
        if (value == 10):
            new_value = 'h'
        else:
            if (value == 0):
                new_value = 'l'
            else:
                new_value = value
        self.write(str.encode('[{0}]\n'.format(new_value)))

# ------------------------------------------------------------------------------
if __name__ == '__main__':

   # dev = TriggerDevice('/./COM20')
    dev = TriggerDevice('COM20')
    state = False
    while True:

        if state:
            dev.set_high()
            state = True
            print('set_high')
        else:
            dev.set_low()
            state = False
            print('set_low')

        #time.sleep(0.001)
    



