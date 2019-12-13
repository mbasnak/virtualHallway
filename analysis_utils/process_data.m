%I've deleted the arguments to dislay side and side velocity - MB 20190808

function [ t, disp_for, disp_side, disp_yaw, fr, angle, vel_for, vel_side, vel_yaw, opto] = process_data( trial_time, trial_data, num_frames)


%function [ t, disp_for, disp_yaw, fr, angle, vel_for, vel_yaw, opto] = process_data( trial_time, trial_data, num_frames)

settings = sensor_settings;

%Asignment of the Daq channels
settings.fictrac_x_DAQ_AI = 4;
%settings.fictrac_yaw_DAQ_AI = 2;
settings.fictrac_yaw_gain_DAQ_AI = 1;
settings.fictrac_x_gain_DAQ_AI = 3; 
settings.fictrac_y_DAQ_AI = 2; 

settings.panels_x_DAQ_AI = 5;
settings.panels_y_DAQ_AI = 6;
settings.opto_DAQ_AI = 8; 

ft_for = trial_data( :, settings.fictrac_x_DAQ_AI ); %data from x channel
%ft_yaw = trial_data( :, settings.fictrac_yaw_DAQ_AI ); %data from yaw channel
ft_yaw = trial_data( :, settings.fictrac_yaw_gain_DAQ_AI ); %I've changed the above line for this one MB 20190809
ft_side = trial_data( :, settings.fictrac_y_DAQ_AI );
panels = trial_data( :, settings.panels_x_DAQ_AI ); %data from the x dimension in panels
raw_opto = trial_data( :, settings.opto_DAQ_AI ); %I don't think I'll need this


%Get filtered position and velocity data using Yvette's
%ficTracSignalDecoding
[ vel_for, disp_for ] = ficTracSignalDecoding(ft_for, settings.sampRate, settings.sensorPollFreq, 20); %uses Yvette's code to filter fictrac's data. I've changing the max velocity from 10 to 20.
[ vel_yaw, disp_yaw ] = ficTracSignalDecoding(ft_yaw, settings.sampRate, settings.sensorPollFreq, 20);
[ vel_side, disp_side ] = ficTracSignalDecoding(ft_side, settings.sampRate, settings.sensorPollFreq, 10);
[ fr, angle] = process_panel_360( panels, num_frames ); %returns filtered and downsampled panel px data as well as calculated angle of the bar
[ t ] = process_time( trial_time ); %downsamples the time
[ opto ] = process_opto( raw_opto ); %downsamples opto triggering data

end

