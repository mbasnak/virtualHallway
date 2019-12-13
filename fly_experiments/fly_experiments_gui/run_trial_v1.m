function [ trial_data, trial_time ] = run_trial_v1(tid, opto_type, experiment_type, task, run_obj, scanimage_client, trial_core_name )

disp(['About to start trial task: ' task]);

% Setup data structures for read / write on the daq board
s = daq.createSession('ni');

% This channel is for external triggering of scanimage 5.1
s.addDigitalChannel('Dev1', 'port0/line0', 'OutputOnly');

% 8:yaw, 9: x, 10: y, 11: panelsx, 12: panelsy, 14:opto, 0: trigger
ai_channels_used = [8:12, 14, 0];
aI = s.addAnalogInputChannel('Dev1', ai_channels_used, 'Voltage');
for i=1:length(ai_channels_used)
    aI(i).InputType = 'SingleEnded';
end

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
%       AI.13 = Opto On %% LOOK INTO THIS
%
% Output channels:
%
%   Dev1:
%       P0.0        = external trigger for scanimage
%
%
% Arduino pins:
%       D2 = appetitive %% LOOK INTO THIS
%       D3 = aversive %% LOOK INTO THIS
%       D4 = voltage range start %% LOOK INTO THIS
%       D5 = voltage range end %% LOOK INTO THIS

settings = sensor_settings;

SAMPLING_RATE = settings.sampRate;
s.Rate = SAMPLING_RATE;
total_duration = run_obj.trial_t;

imaging_trigger = zeros(SAMPLING_RATE*total_duration,1);
imaging_trigger(2:end-1) = 1.0;

output_data = [imaging_trigger];
queueOutputData(s, output_data);

% Trigger scanimage run if using 2p.
if(run_obj.using_2p == 1)
    scanimage_file_str = ['cdata_' trial_core_name '_tt_' num2str(total_duration) '_'];
    fprintf(scanimage_client, [scanimage_file_str]);
    disp(['Wrote: ' scanimage_file_str ' to scanimage server' ]);
    acq = fscanf(scanimage_client, '%s');
    disp(['Read acq: ' acq ' from scanimage server' ]);    
end

      
cur_trial_corename = [experiment_type '_' opto_type '_' task '_' datestr(now, 'yyyymmdd_HHMMSS') '_sid_' num2str(run_obj.session_id) '_tid_' num2str(tid)];
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
%Panel_com('enable_extern_trig');


system(['python run_experiment.py ' num2str(total_duration) ' ' experiment_type ' "' hdf_file '" "' opto_type '" ' num2str(run_obj.stim_angle) ' ' num2str(run_obj.stim_angle_relative) ' 1 &']);
[trial_data, trial_time] = s.startForeground();
Panel_com('stop');
Panel_com('all_off');
system('exit');
release(s);
Panel_com('disable_extern_trig');
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
%set closed loop for x
Panel_com('set_mode', [4, 0]);
Panel_com('set_funcx_freq' , freq);
Panel_com('set_posfunc_id', [1, func]);
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
%set closed loop for x
Panel_com('set_mode', [3, 4]);
%Panel_com('set_funcx_freq' , freq);
Panel_com('set_posfunc_id', [2, func]);
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
%set closed loop for x
Panel_com('set_mode', [3, 3]);
%Panel_com('set_funcx_freq' , freq);
%Panel_com('set_posfunc_id', [2, func]);
Panel_com('set_position', [startPosition, 1]);
%quiet mode on
Panel_com('quiet_mode_on');
end
