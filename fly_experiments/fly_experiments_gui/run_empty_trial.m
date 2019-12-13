function [ trial_data, trial_time ] = run_empty_trial(tid, task, run_obj, scanimage_client, trial_core_name )
cd('C:\Users\wilson_lab\Desktop\MelanieFictrac\conditioned_menotaxis-master\experiment');

disp(['About to start trial task: ' task]);

% Setup data structures for read / write on the daq board
s = daq.createSession('ni');

% This channel is for external triggering of scanimage 5.1
s.addDigitalChannel('Dev1', 'port0/line0', 'OutputOnly');
s.addAnalogOutputChannel('Dev1', 1, 'Voltage'); %output for LED driver

ai_channels_used = [1:3,11:15];

aI = s.addAnalogInputChannel('Dev3', ai_channels_used, 'Voltage');
for i=1:length(ai_channels_used)
    aI(i).InputType = 'SingleEnded';
end

aI(9) = s.addAnalogInputChannel('Dev1', 12, 'Voltage');
aI(9).InputType = 'SingleEnded';

settings = sensor_settings;

SAMPLING_RATE = settings.sampRate;
s.Rate = SAMPLING_RATE; %sampling rate for the session (Jenny is using 4000 Hz)
total_duration = 10; %trial duration taken from the GUI input

imaging_trigger = zeros(SAMPLING_RATE*total_duration,1); %set the size for the imaging trigger
imaging_trigger(2:end-1) = 1.0;

if run_obj.experiment_number == 6
    opto_trigger = [zeros(SAMPLING_RATE*run_obj.pre_training, 1); ones(SAMPLING_RATE*run_obj.training, 1); zeros(SAMPLING_RATE*(total_duration - run_obj.pre_training - run_obj.training), 1)];
else
    opto_trigger = zeros(SAMPLING_RATE*total_duration, 1);
end

output_data = [imaging_trigger, opto_trigger]; %I don't understand how this output data is triggering things, especially for the opto
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

cur_trial_corename = [experiment_type '_' task '_' datestr(now, 'yyyymmdd_HHMMSS') '_sid_' num2str(run_obj.session_id) '_tid_' num2str(tid)];
cur_trial_file_name = [ run_obj.experiment_ball_dir '\hdf5_' cur_trial_corename '.hdf5' ];

hdf_file = cur_trial_file_name;
    

system(['python run_aout_empty.py ' ' 1 &']); %run just the analogout.py code

[trial_data, trial_time] = s.startForeground();


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
    elseif experiment_number == 7
        experiment_name = 'virtualHallway';
    else
        experiment_name = 'spontaneous';
    end
end