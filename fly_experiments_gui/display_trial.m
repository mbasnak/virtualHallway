function [fwd_histo, ang_histo, panel_histo] = display_trial( task, tid, run_obj, trial_time, trial_data, viz_figs, fwd_histogram, ang_histogram, panel_histogram)

settings = sensor_settings;

%%
[ t, disp_for, disp_side, disp_yaw, fr, angle, vel_for, vel_side, vel_yaw , opto] = process_data( trial_time, trial_data, run_obj.number_frames); 

fwd_histo = [fwd_histogram; vel_for];
ang_histo = [ang_histogram; vel_yaw];
panel_histo = [panel_histogram; angle];


%% Display trial velocities
figure(viz_figs.data_fig);

% Revise text
set(viz_figs.text_sidtid, 'String', ['Session ID: ' num2str(run_obj.session_id) ' | Trial ID: ' num2str(tid)]);

if ( strcmp(run_obj.loop_type_str, 'Optokinetic') == 1)
    set(viz_figs.text_trialtype, 'String', ['Panel Loop: ' run_obj.loop_type_str ' | Trial type: ' task ' Opto Type: ' run_obj.opto_type]);
end

% Panels subplot

%%%%%%% added the following lines to plot the changes in stim %%%%%%% MB
%%%%%%% 20191104

% x dimension
subplot(viz_figs.panels_ax);
plot(t, fr);
ylim([0 96]);
hold on
ydimension = trial_data( :, 6);
n = floor(settings.sampRate/settings.sensorPollFreq);
ydimension = downsample(ydimension,n);
plot(t, ydimension*9.6);
legend({'x dimension', 'ydimension*48'});


% Opto subplot
if (run_obj.opto_on == 1)
    subplot(viz_figs.opto_ax);
    plot(t, opto);
    ylabel('Volts');
else
    subplot(viz_figs.opto_ax);
    set(gca, 'Visible', 'off');
end

% Fwd subplot
subplot(viz_figs.fwd_ax);
plot(t, vel_for);
ylabel('Forward Velocity');
ylim([-2 6]);

% Angular velocity subplot
subplot(viz_figs.ang_ax);
plot(t, vel_yaw);
ylabel('Yaw Velocity');
ylim([-10 10]);
xlabel('Time (s)');

% Fwd histogram
subplot(viz_figs.fwd_histo);
histogram(fwd_histo);
xlabel('Fwd Velocity');
xlim([-10 30]);

% Angular histogram OR angular plot of all trials depending on experiment
% condition
if ( strcmp(run_obj.loop_type_str, 'Optokinetic') == 1)
    subplot(viz_figs.ang_histo);
    plot(t, vel_yaw);
    ylabel('Yaw Velocity');
    hold on;
else
    subplot(viz_figs.ang_histo);
    histogram(ang_histo);
    xlabel('Yaw Velocity');
end

% Circular plot trial
subplot(viz_figs.circular_trial);
polarhistogram(deg2rad(angle), 24);
title('Trial Polar Histogram');
set(viz_figs.circular_trial, 'ThetaZeroLocation', 'top');
set(viz_figs.circular_trial, 'ThetaDir', 'clockwise');
set(viz_figs.circular_trial, 'ThetaColor', [.5 .5 .5]);
set(viz_figs.circular_trial, 'RTick', []);
g = get(viz_figs.circular_trial, 'OuterPosition');
set(viz_figs.circular_trial, 'OuterPosition', [g(1) g(2) .34 .34]);


% Circular plot all trials
subplot(viz_figs.circular_all);
polarhistogram(deg2rad(panel_histo), 24);
title('All Trials');
set(viz_figs.circular_all, 'ThetaZeroLocation', 'top');
set(viz_figs.circular_all, 'ThetaDir', 'clockwise');
set(viz_figs.circular_all, 'ThetaColor', [.5 .5 .5]);
set(viz_figs.circular_all, 'RTick', []);
g = get(viz_figs.circular_all, 'OuterPosition');
set(viz_figs.circular_all, 'OuterPosition', [g(1) g(2) .34 .34]);


end

