import os
import sys
sys.path.insert(0, os.path.abspath('C:/Users/wilson_lab/Desktop/MelanieFictrac/conditioned_menotaxis-master')) #sets this folder as path
from fictrac_2d import FicTrac2D #imports FicTrac2D module, which updates fly's data

def fictrac2dcode(experiment=None, time=None, jump_time=None, hold_time=None, pre_training=None, training=None, goal_change=None, goal_window=None, arduino=None, logfile=None, analog_out=None, probe_status=None):
    time_param = time or '1800'
    experiment_param = experiment or '1'
    jump_time_param = jump_time or '100'
    pre_training_param = pre_training or '600'
    training_param = training or '600'
    goal_change_param = goal_change or '180'
    goal_window_param = goal_window or '90'
    hold_time_param = hold_time or '3'
    experiment_param = {
        'experiment': int(experiment_param), #the experiment number determines the experiment type, with
        # 1 being spontaneous walking, 2 being menotaxis, 3 being conditioned menotaxis, 4 jump and hold, 5 hallway and 6 fictive sugar
        'experiment_time': int(time_param), #this is the trial length
        'jump_time': int(jump_time_param), #for menotaxis, time between bar jumps
        'hold_time': int(hold_time_param), #I'm not sue what this means. Maybe it leaves the loop open for a certain amount of time before closed-loop resumes?
        'goal_change': int(goal_change_param), #I'm not sure what this refers to but I likely won't use it
        'goal_window': int(goal_window_param), #same
        'pre_training': int(pre_training_param), #This is probably some time menotaxing before conditioning starts
        'training': int(training_param), #time with opto conditioning
        'arduino': bool(int(arduino)) or False,  #because of how the matlab code run_trial is done, this will be arduino for any experiment other than spontaneous walking
        'logfile_name': logfile or 'Z:/Wilson Lab/Mel/FlyOnTheBall/data/data.hdf5', #this file will be saved in the experiment directory we choose in the GUI I believe, because of the matlab code
        'logfile_auto_incr': True,
        'logfile_auto_incr_format': '{0:06d}',
        'logfile_dt': 0.01,
        #'trigger_device_port': '/./COM20',
        'trigger_device_port': 'COM20',
        'analog_out': analog_out or False,
        'gain_yaw': 0.8, #add gain for yaw
        'gain_x': 1, #and for x
        'probe_status': bool(int(probe_status)) or False
    }
    client2 = FicTrac2D(experiment_param) #use the parameters to run FicTrac2D, found in fictrac_2d.py
    client2.run()

if __name__ == '__main__':

    """
    ARGV: 
    1: experiment, 
    2: experiment time,
    3: jump_time,
    4: hold time
    5: pre_training,
    6: training,
    7: goal_change, 
    8: goal_window,
    9: arduino,
    10: logfile
    """

    if len(sys.argv) > 1:    #from the list of arguments given to the system by the matlab code run_trial
        experiment = int(sys.argv[1]) #make the first argument be the experiment...
        time = float(sys.argv[2]) #...etc
        jump_time = float(sys.argv[3])
        hold_time = float(sys.argv[4])
        pre_training = float(sys.argv[5])
        training = float(sys.argv[6])
        goal_change = float(sys.argv[7])
        goal_window = float(sys.argv[8])
        arduino = bool(int(sys.argv[9]))
        logfile = sys.argv[10]
        analog_out = True
        if len(sys.argv) > 10:
            probe_status = bool(int(sys.argv[11]))
        else:
            probe_status = False
        fictrac2dcode(experiment, time, jump_time, hold_time, pre_training, training, goal_change, goal_window, arduino, logfile, analog_out, probe_status)
    else:
        fictrac2dcode()
