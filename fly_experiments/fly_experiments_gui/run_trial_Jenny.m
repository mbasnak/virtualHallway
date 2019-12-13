function [ trial_data, trial_time ] = run_trial(tid, task, run_obj, scanimage_client, trial_core_name )
cd('C:\Users\wilson_lab\Desktop\MelanieFictrac\conditioned_menotaxis-master\experiment');

% Currently v2
disp(['About to start trial task: ' task]);

% Setup data structures for read / write on the daq board
s = daq.createSession('ni');

s.addDigitalChannel('Dev1', 'port0/line0', 'OutputOnly');
s.addAnalogOutputChannel('Dev1', 1, 'Voltage'); %output for LED driver

ai_channels_used = [1:3,11:15];

aI = s.addAnalogInputChannel('Dev3', ai_channels_used, 'Voltage');
for i=1:length(ai_channels_used)
    aI(i).InputType = 'SingleEnded';
end

aI(9) = s.addAnalogInputChannel('Dev1', 12, 'Voltage');
aI(9).InputType = 'SingleEnded';
% Add output channels for olfactometer exp to arduino (2-6) and camera trigger (7)
%s.addAnalogOutputChannel('Dev1', [1], 'Voltage');

% Input channels:
%
%   Dev1:
%       AI.8 = FicTrac X
%       AI.9 = FicTrac Yaw
%       AI.10 = FicTrac Y
%       AI.11 = Panels Position
%       AI.4 = frame clock
%       AI.12 = frame clock
%       AI.13 = Opto On
%
% Output channels:
%
%   Dev1:
%       P0.0        = external trigger for scanimage
%

settings = sensor_settings;

SAMPLING_RATE = settings.sampRate;
s.Rate = SAMPLING_RATE;
total_duration = run_obj.trial_t;

imaging_trigger = zeros(SAMPLING_RATE*total_duration,1);
imaging_trigger(2:end-1) = 1.0;

if run_obj.experiment_number == 6
    opto_trigger = [zeros(SAMPLING_RATE*run_obj.pre_training, 1); ones(SAMPLING_RATE*run_obj.training, 1); zeros(SAMPLING_RATE*(total_duration - run_obj.pre_training - run_obj.training), 1)];
else
    opto_trigger = zeros(SAMPLING_RATE*total_duration, 1);
end

output_data = [imaging_trigger, opto_trigger];
queueOutputData(s, output_data);

% Trigger scanimage run if using 2p.
if(run_obj.using_2p == 1)
    scanimage_file_str = ['cdata_' trial_core_name '_tt_' num2str(total_duration) '_'];
    fprintf(scanimage_client, [scanimage_file_str]);
    disp(['Wrote: ' scanimage_file_str ' to scanimage server' ]);
    acq = fscanf(scanimage_client, '%s');
    disp(['Read acq: ' acq ' from scanimage server' ]);    
end

experiment_type = classify_opto(run_obj.experiment_number);
arduino = double(~run_obj.experiment_number == 1);

cur_trial_corename = [experiment_type '_' task '_' datestr(now, 'yyyymmdd_HHMMSS') '_sid_' num2str(run_obj.session_id) '_tid_' num2str(tid)];
cur_trial_file_name = [ run_obj.experiment_ball_dir '\hdf5_' cur_trial_corename '.hdf5' ];

hdf_file = cur_trial_file_name;
    
% Begin Panels 
if ( strcmp(task, 'ClosedLoop') == 1 )
    if run_obj.start_frame == 0
        start = randi(96);
    else start = run_obj.start_frame;
    end
    closedLoop(run_obj.pattern_number, start);
elseif ( strcmp(task, 'OpenLoop') == 1 )
    openLoop(run_obj.pattern_number, run_obj.function_number);
elseif ( strcmp(task, 'OpenLoopRight') == 1 )
    openLoop(run_obj.pattern_number, 2);
elseif ( strcmp(task, 'OpenLoopLeft') == 1 )
    openLoop(run_obj.pattern_number, 1);
elseif ( strcmp(task, 'Off') == 1)
    closedLoop(run_obj.pattern_number, 1);
elseif ( strcmp(task, 'Closed_Loop_X_Open_Loop_Y') == 1)
    if run_obj.start_frame == 0
        start = randi(96);
    else start = run_obj.start_frame;
    end
    closedOpenLoop(run_obj.pattern_number, run_obj.function_number, start); 
elseif ( strcmp(task, 'Closed_Loop_X_Closed_Loop_Y') == 1)
    if run_obj.start_frame == 0
        start = randi(96);
    else start = run_obj.start_frame;
    end
    closedClosedLoop(run_obj.pattern_number, start); 
end


Panel_com('start');

system(['python run_experiment.py ' num2str(run_obj.experiment_number) ' ' num2str(run_obj.trial_t) ' ' num2str(run_obj.bar_jump_time) ' '...
    num2str(run_obj.hold_time) ' ' num2str(run_obj.pre_training) ' ' num2str(run_obj.training) ' ' num2str(run_obj.goal_change) ' ' num2str(run_obj.goal_window) ' '...
    num2str(arduino) ' "' hdf_file '" ' ' 1 &']);

[trial_data, trial_time] = s.startForeground();

Panel_com('stop');
Panel_com('all_off');
system('exit');
release(s);
end

function experiment_name = classify_opto(experiment_number)
    if experiment_number == 2
        experiment_name = 'menotaxis';
    elseif experiment_number == 3
        experiment_name = 'conditionedmenotaxis';
    elseif experiment_number == 4
        experiment_name = 'jump_hold';
    elseif experiment_number == 5
        experiment_name = 'hallway';
    elseif experiment_number == 6
        experiment_name = 'fictivesugar';
    else
        experiment_name = 'spontaneous';
    end
end

function closedLoop(pattern, startPosition)
%% begins closedLoop setting in panels
Panel_com('stop');
%set arena
Panel_com('set_config_id', 1);
%set brightness level
Panel_com('g_level_7');
%set pattern number
Panel_com('set_pattern_id', pattern);
Panel_com('set_position', [startPosition, 1]);
%set closed loop for x
Panel_com('set_mode', [3, 0]);
Panel_com('quiet_mode_on');
Panel_com('all_off');
end

function openLoop(pattern, func)
%% begins closedLoop setting in panels
freq = 50;
Panel_com('stop');
%set pattern number
Panel_com('set_pattern_id', pattern);
%set open loop for x
Panel_com('set_mode', [4, 0]);
Panel_com('set_funcX_freq' , freq);
Panel_com('set_posFunc_id', [1, func]);
Panel_com('set_position', [95, 1]);
%quiet mode on
Panel_com('quiet_mode_on');
end

function closedOpenLoop(pattern, func, startPosition)
%% begins closedLoop setting in panels
freq = 50;
Panel_com('stop');
Panel_com('g_level_7');
%set pattern number
Panel_com('set_pattern_id', pattern);
%set closed loop for x , open loop y
Panel_com('set_mode', [3, 4]);
Panel_com('set_funcY_freq' , freq);
Panel_com('set_posFunc_id', [2, func]);
Panel_com('set_position', [startPosition, 1]);
%quiet mode on
Panel_com('quiet_mode_on');
end

function closedClosedLoop(pattern, startPosition)
%% begins closedLoop setting in panels
freq = 50;
Panel_com('stop');
Panel_com('g_level_7');
%set pattern number
Panel_com('set_pattern_id', pattern);
%set closed loop for x and y
Panel_com('set_mode', [3, 3]);
Panel_com('set_position', [startPosition, 1]);
%quiet mode on
Panel_com('quiet_mode_on');
end
