from __future__ import print_function

import time
import redis
import json
import signal

from . import utils
from .fly_data import FlyData
from .trigger_device import TriggerDevice
from .protocol import Protocol
from .h5_logger import H5Logger
from .analogout import FicTracAout

class FicTrac2D(object):

    """
    Implements the experiment. Take input via PUB/SUB fictrac output channel.
    Updates fly data.
    Uses protocol to determine the appropriate panels out and if opto is on.
    Calls analogout to output parameters.

    Jenny Lu 5-9-2019

    """

    default_param = {
        'experiment': 1,
        'experiment_time': 30,
        'jump_time': 120,
        'hold_time': 3,
        'goal_change': 180,
        'goal_window': 90,
        'pre_training': 600,
        'training': 600,
        'logfile_name': 'Z:/Wilson Lab/Mel/FlyOnTheBall/data',
        'logfile_auto_incr': True,
        'logfile_auto_incr_format': '{0:06d}',
        'logfile_dt': 0.01,
        'trigger_device_port': '/./COM20', #I changed this port -MB 20190813
        'arduino': False,
        'analog_out': False,
        'gain_yaw': 0.8,
        'gain_x': 1,
        'probe_status': False
    }

    def __init__(self, param = default_param):
        self.param = param
        self.data = FlyData() #get the data from fictrac through FlyData's module, in fly_data.py
        self.protocol = Protocol(self.param) #get the protocol paramteres through Protocol, in protocol.py
        self.analog_out = self.param['analog_out']
        self.gain_yaw = self.param['gain_yaw']
        self.gain_x = self.param['gain_x']
        if self.analog_out: #if the parameter analog_out is defined as true (which it is in run_experiment.py)
            self.aout = FicTracAout() #define the output as the one given in the alaogout.py code.
        self.logger = H5Logger(
                filename = self.param['logfile_name'],
                auto_incr = self.param['logfile_auto_incr'],
                auto_incr_format = self.param['logfile_auto_incr_format'],
                param_attr = self.param
                )
        self.experiment_time = self.param['experiment_time']
        self.reset()

        #I'm adding this variable to get the voltage output - MB 20190806
        self.voltage_out = 0
        #I'm adding a parameter that will be the time when the fly reaches the end of the hallway - MB 20190805
        self.final_time = 10000000000
        self.reward_time = 10000000000
        #I'm getting the experiment number as well
        self.experiment = self.param['experiment']
        self.probe_status = self.param['probe_status']
        ############################

        if self.param['arduino']:
            self.trigger_device = TriggerDevice(self.param['trigger_device_port'])

        # Setup message queue, redis and worker thread
        self.redis_client = redis.StrictRedis()
        self.pubsub = self.redis_client.pubsub()
        self.pubsub.subscribe('fictrac')

        if self.experiment == 7:
            self.end_sequence = False
            self.reward_sequence = False

        self.done = False
        signal.signal(signal.SIGINT,self.sigint_handler)



    def reset(self):
        self.data.reset()
        self.protocol.reset()
        self.time_start = time.time()
        self.time_now = self.time_start
        self.time_log = None
      #  if self.experiment == 7:
        self.end_sequence = False
        self.reward_sequence = False

    @property
    def time_elapsed(self):
        return self.time_now - self.time_start

    def run(self):
        if self.param['arduino']: 
            self.trigger_device.set_low()  #Set the trigger device (arduino COM port defined in trigger_device.py) to low
        while not self.done: #while the time elapsed is less than the experiment time

            # Pull latest redis message from queue
            for item in self.pubsub.listen(): #listen to the redis channel

                # GET TIME
                self.time_now = time.time()
                utils.flush_print('time listened         = {0:1.3f}'.format(self.time_elapsed))

                # New message from fictrac - convert from json to python dictionary
                message = item['data']
                try:
                    data = json.loads(message)
                except TypeError:
                    continue
                if data['type'] == 'reset':
                    # This is a reset message which indicates that FicTrac has been restarted
                    self.on_reset_message(data)
                else:
                    # UPDATE DATA
                    self.data.add(self.time_elapsed, data) #add to the data matrix defined in fly_data the incoming data points
                    utils.flush_print('time data          = {0:1.3f}'.format(self.time_elapsed))


                    # UPDATE ANALOG OUT
                    if self.analog_out:
                        self.aout.output_voltage(self.data) #send the analog output through the phidgets device (using analogout.py code)
                        #I'm adding the line below to get the voltage output from the x gain channel-MB 20190806
                        self.voltage_out = self.aout.voltage_out(self.data)

                        # UPDATE PROTOCOL
                        self.protocol.update_panel(self.time_elapsed,
                                                   self.data, self.voltage_out, self.probe_status)  # update the pannel values with the apropriate jump magnitudes
                        self.data.update_panel_heading(self.time_elapsed, self.protocol.panel_jump, self.gain_yaw,
                                                       self.protocol.open_loop,
                                                       self.protocol.open_loop_value)  # update the yaw movement of the pattern in the panels
                        self.data.update_panel_x(self.gain_x, self.protocol.open_loop_x,
                                                 self.protocol.open_loop_value_x)  # update the x movement of the pattern in the panels
                        utils.flush_print('time protocol         = {0:1.3f}'.format(self.time_elapsed))

                        self.protocol.update_opto(self.time_elapsed, self.data, self.voltage_out)

                        #I'm moving the pulse triggering here so that it only happens at the beginning - MB 20190903
                        if self.param['arduino'] and not self.param['probe_status'] and not self.reward_sequence:  # if the arduino is defined and this is not a probe trial
                            self.trigger_device.set_value(self.protocol.pulse_value)  # this sends the trigger signals to the arduino, although I think now they're always set at 0
                            utils.flush_print('pulse value        = {0:1.3f}'.format(self.protocol.pulse_value))
                        utils.flush_print('time pulse         = {0:1.3f}'.format(self.time_elapsed))


                        #I'm adding a conditional statement such that if the stimulus has expanded fully, then the final time should be set to the current time-MB 20190806
                        if (not self.end_sequence) and (self.protocol.end_sequence_virtualHallway):
                            self.final_time = self.time_elapsed
                            self.end_sequence = True
                        elif not self.end_sequence:
                            self.final_time = 10000000000

                        if (not self.reward_sequence) and (self.protocol.reward_sequence_virtualHallway):
                            self.reward_time = self.time_elapsed
                            self.reward_sequence = True
                        elif not self.reward_sequence:
                            self.reward_time = 10000000000

                    utils.flush_print('time aout         = {0:1.3f}'.format(self.time_elapsed))
                    utils.flush_print('output_voltage_x_gain         = {0:1.3f}'.format(self.voltage_out))
                    utils.flush_print('final_time         = {0:1.3f}'.format(self.final_time))
                    utils.flush_print('end_sequence         = {0:1.3f}'.format(self.end_sequence))
                    utils.flush_print('reward_time         = {0:1.3f}'.format(self.reward_time))
                    utils.flush_print('reward_sequence         = {0:1.3f}'.format(self.reward_sequence))



                    # LOG FILE
                    self.write_logfile() #save all the data in a log file
                    utils.flush_print('time log         = {0:1.3f}'.format(self.time_elapsed))

                    # PRINT SOMETHING
                    utils.flush_print('time          = {0:1.3f}'.format(self.time_elapsed))
                    utils.flush_print('frame         = {0}'.format(self.data.frame))
                    utils.flush_print('heading         = {0:1.3f}'.format(self.data.heading))
                    utils.flush_print('panelheading         = {0:1.3f}'.format(self.data.panel_heading))
                    utils.flush_print('panelx         = {0:1.3f}'.format(self.data.panel_x))
                    utils.flush_print('velx         = {0:1.3f}'.format(self.data.velx))
                    utils.flush_print('goalheading         = {0:1.3f}'.format(self.data.goal_heading))
                    utils.flush_print()

                # END EXPERIMENT IF TIME ELAPSED
                #I'm changing this so that it only works for experiments 1-6
                if self.experiment != 7:
                    if self.time_elapsed > self.experiment_time:
                        self.done = True
                        break

                #added this to make the trial end when the fly reaches the reward location - added by MB 20190805
                else:
                    # if the animal has reached the reward, wait 0.5 s and turn off the pulse
                    if self.reward_sequence and self.time_elapsed > self.reward_time + 0.5:
                        self.trigger_device.set_value(0)  # turn the LED off
                        self.protocol.end_reward_virtualHallway = True

                    # if animal has reached the end of the hallway, keep acquiring for 1 s
                    if self.end_sequence and self.time_elapsed > self.final_time + 1.0:
                        self.done = True
                        break

                    # also end the trial if you've run out of time
                    if self.time_elapsed > self.experiment_time:
                        self.done = True
                        break



        # END OF EXPERIMENT
        utils.flush_print()
        utils.flush_print('Run finshed - quiting!')
        self.clean_up()

    def on_reset_message(self,message):
        utils.flush_print('reset')
        self.reset()

    def write_logfile(self):
        if self.time_log is None or ((self.time_elapsed - self.time_log) >  self.param['logfile_dt']):
            self.time_log = self.time_elapsed
            log_data = {
                'time': self.time_elapsed,
                'frame': self.data.frame,
                'posx': self.data.posx,
                'posy': self.data.posy,
                'velx': self.data.velx,
                'vely': self.data.vely,
                'intx': self.data.intx,
                'inty': self.data.inty,
                'heading': self.data.heading,
                'panel heading': self.data.panel_heading,
                'goal heading': self.data.goal_heading,
                'new goal heading': self.protocol.new_goal_heading,
                'panel jump': self.protocol.panel_jump,
                'open loop': self.protocol.open_loop,
                'open loop value': self.protocol.open_loop_value,
                'panel x': self.data.panel_x,
                'open loop x': self.protocol.open_loop_x,
                'open loop value x': self.protocol.open_loop_value_x,
                'pulse_on': self.protocol.pulse_value
            }
            self.logger.add(log_data)

    def sigint_handler(self, signum, frame):
        self.done = True

    def clean_up(self):
        self.logger.reset()
        if self.param['arduino'] and self.trigger_device.isOpen():
            self.trigger_device.set_value(0)