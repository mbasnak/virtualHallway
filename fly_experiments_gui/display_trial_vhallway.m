function [fwd_histo, ang_histo, trial_dur_all_Trials,fwd_vel,ang_vel,panels_y,probe_Status,empty_Trials] = display_trial_vhallway( task, tid, run_obj, trial_time, trial_data, viz_figs, fwd_histogram, ang_histogram, trial_dur_all_trials, probe_status,fwd_vel,ang_vel,panels_y,probe_Status,empty_Trials,empty_status)

settings = sensor_settings;

%%
[ t, disp_for, disp_side, disp_yaw, fr, angle, vel_for, vel_side, vel_yaw , opto] = process_data( trial_time, trial_data, run_obj.number_frames); 

fwd_histo = [fwd_histogram; vel_for];
ang_histo = [ang_histogram; vel_yaw];
trial_dur_all_Trials = [trial_dur_all_trials; max(t)];
fwd_vel{1,tid+1} = vel_for;
ang_vel{1,tid+1} = abs(vel_yaw);
panels_y{1,tid+1} = process_panel_y(trial_data(:,6),92); %92 is the total dimension number and 6 is the ypanels channel
probe_Status(tid+1) = probe_status;
empty_Trials(tid+1) = empty_status;

%downsample fwd vel to the shortest trial
for i = 1:length(fwd_vel)
    sizes(i) = size(fwd_vel{1,i},1);
end
minLength = min(sizes);

for i = 1:length(fwd_vel)
    idx = 1:size(fwd_vel{1,i},1);
    idxq = linspace(min(idx), max(idx), minLength);
    all_fwd_vel(:,i) = interp1(idx, fwd_vel{1,i}, idxq, 'linear');
end
all_fwd_vel(all_fwd_vel>10) = 10;
all_fwd_vel(all_fwd_vel<-5) = -5;

%downsample ang vel to the shortest trial
for i = 1:length(ang_vel)
    sizesAng(i) = size(ang_vel{1,i},1);
end
minLength = min(sizes);

for i = 1:length(ang_vel)
    idx = 1:size(ang_vel{1,i},1);
    idxq = linspace(min(idx), max(idx), minLength);
    all_ang_vel(:,i) = interp1(idx, ang_vel{1,i}, idxq, 'linear');
end
all_ang_vel(all_ang_vel>10) = 10;


%% Display trial velocities
figure(viz_figs.data_fig);

% Revise text
set(viz_figs.text_sidtid, 'String', ['Session ID: ' num2str(run_obj.session_id) ' | Trial ID: ' num2str(tid)]);

% Add text if it is a probe trial
if probe_status == 1
    set(viz_figs.text_optostatus, 'String',['Opto status: This is a probe trial']);
else
    if empty_status == 1
    set(viz_figs.text_optostatus, 'String',['Opto status: This is an empty trial']);    
    else
    set(viz_figs.text_optostatus, 'String',['Opto status: This is an opto trial']); 
    end
end


% X position subplot. There's something weird with this position
subplot(viz_figs.accumx_ax);
plot(t, panels_y{1,tid+1});
hold on
%plot(t,opto*(max(panels_y{1,tid+1})/5),'r');
plot(t,opto*2,'r');
hold off
ylabel('y dimension');
xlim([0 max(t)]);
ylim([0,13]);

% Fwd subplot
subplot(viz_figs.fwd_ax);
plot(t, vel_for);
hold on
plot(t,opto,'r');
hold off
ylabel('Forward Velocity');
ylim([-2 6]);
xlim([0 max(t)]);

% Angular speed subplot
subplot(viz_figs.ang_ax);
plot(t, abs(vel_yaw));
hold on
plot(t,opto,'r');
hold off
ylabel('Yaw speed');
ylim([0 10]);
xlabel('Time (s)');
xlim([0 max(t)]);

% Fwd histogram
subplot(viz_figs.fwd_histo);
histogram(fwd_histo);
xlabel('Fwd Velocity');
xlim([-5 10]);

% Angular histogram
subplot(viz_figs.ang_histo);
histogram(ang_histo);
xlabel('Yaw Velocity');
xlim([-10 10]);

% Forward velocity raster plot
subplot(viz_figs.fwd_raster);
colormap(hot)
imagesc(all_fwd_vel');
colorbar
set(gca,'XTick',[], 'YTick', [])

% Forward velocity vs distance travelled
% subplot(viz_figs.fwd_raster);
% plot(panels_y{1,tid+1},fwd_vel{1,tid+1},'.');
% xlabel('y dimension'); ylabel('forward velocity (mm/s)');
% xlim([0 13]);


% Angular speed raster plot
subplot(viz_figs.ang_raster);
imagesc(all_ang_vel');
colorbar
set(gca,'XTick',[], 'YTick', [])

% Evolution of trial duration
subplot(viz_figs.trial_dur);
trialNum = [1:length(trial_dur_all_Trials)];
plot(trialNum(probe_Status==1),trial_dur_all_Trials(probe_Status==1),'ko','MarkerFaceColor','k');
hold on
plot(trialNum(probe_Status==0 & empty_Trials==0),trial_dur_all_Trials(probe_Status==0 & empty_Trials==0),'ro','MarkerFaceColor','r');
plot(trialNum(probe_Status==0 & empty_Trials==1),trial_dur_all_Trials(probe_Status==0 & empty_Trials==1),'ko','MarkerFaceColor','w');
hold off
xlabel('Trial number');
ylabel('Trial duration (s)');
set(gca,'XTick',[])


end


