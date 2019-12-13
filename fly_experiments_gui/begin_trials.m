function [ output_args ] = begin_trials( run_obj )

task_cnt = run_obj.num_trials;

scanimage_client_skt = '';
if(run_obj.using_2p == 1)
    scanimage_client_skt = connect_to_scanimage();
    disp(['Connected to scanimage server on socket.']);
end

% Data visualization figure
% I'm adding an if/else to the data viz so that it's different for the
% virtual hallway than the other excperiments -MB 20180823
if run_obj.experiment_number ~= 7
    viz_figs.data_fig = figure();
    set(viz_figs.data_fig,'Units','inches','Position',[0 0 10 10]);
    set(viz_figs.data_fig,'color','w');
    viz_figs.info_ax = subtightplot(7,7,[1:7], [.05 .05], [.1, .1], [.1, .1]);
    viz_figs.info_ax.Visible = 'Off';
    xlim(viz_figs.info_ax, [0 1]);
    ylim(viz_figs.info_ax, [0 1]);
    viz_figs.text_expname = text( 0, 1, ['Experiment Name: ' char(run_obj.expname)], 'FontSize', 12); %viz_figs.info_ax as first arg
    viz_figs.text_sidtid = text(0, .8, ['Session ID: ' num2str(run_obj.session_id) ' | Trial ID: '], 'FontSize', 12); %same
    viz_figs.text_datetime = text(0, .6, ['Date / Time: ' datestr(run_obj.time)], 'FontSize', 12); %same
    viz_figs.text_trialtime = text(.5, .6, ['Trial time: ' num2str(run_obj.trial_t) ' sec | ITI: ' num2str(run_obj.inter_trial_t)], 'FontSize', 12); %same
    viz_figs.text_trialtime = text(.5, .8, ['Num trials: ' num2str(run_obj.num_trials)], 'FontSize', 12); %same
    viz_figs.text_trialtype = text(.5, 1, ['Panel Loop: ' run_obj.loop_type_str ' | Opto Type: ' run_obj.opto_type] , 'FontSize', 12, 'Interpreter', 'none'); %same   
    viz_figs.panels_ax = subtightplot(7,7,[8:11], [.05 .05], [.1, .1], [.1, .1]);
    viz_figs.opto_ax = subtightplot(7,7,[15:18], [.05 .05], [.1, .1], [.1, .1]);
    viz_figs.fwd_ax = subtightplot(7,7,[22:25], [.05 .05], [.1, .1], [.1, .1]);
    viz_figs.ang_ax = subtightplot(7,7,[29:32], [.05 .05], [.1, .1], [.1, .1]);
    viz_figs.fwd_histo = subtightplot(7,7,[36:39], [.05 .05], [.1, .1], [.1, .1]);
    viz_figs.ang_histo = subtightplot(7,7,[43:46], [.05 .05], [.1, .1], [.1, .1]);
    viz_figs.circular_trial = subplot(7,7,[12:14,19:21, 26:28],polaraxes); %polaraxes after the coma
    viz_figs.circular_all = subplot(7,7,[33:35,40:42, 47:49],polaraxes); %polaraxes after the coma
else %I'm plotting a different figure for the virtual hallway.
    viz_figs.data_fig = figure();
    set(viz_figs.data_fig,'Units','inches','Position',[0 0 10 10]);
    set(viz_figs.data_fig,'color','w');
    viz_figs.info_ax = subtightplot(7,7,[1:7], [.05 .05], [.1, .1], [.1, .1]);
    viz_figs.info_ax.Visible = 'Off';
    xlim(viz_figs.info_ax, [0 1]);
    ylim(viz_figs.info_ax, [0 1]);
    viz_figs.text_expname = text( 0, 1, ['Experiment Name: ' char(run_obj.expname)], 'FontSize', 12); %viz_figs.info_ax as first arg
    viz_figs.text_sidtid = text(0, .8, ['Session ID: ' num2str(run_obj.session_id) ' | Trial ID: '], 'FontSize', 12); %same
    viz_figs.text_datetime = text(0, .6, ['Date / Time: ' datestr(run_obj.time)], 'FontSize', 12); %same
    viz_figs.text_trialtime = text(.5, .6, ['Trial time: ' num2str(run_obj.trial_t) ' sec | ITI: ' num2str(run_obj.inter_trial_t)], 'FontSize', 12); %same
    viz_figs.text_trialtime = text(.5, .8, ['Num trials: ' num2str(run_obj.num_trials)], 'FontSize', 12); %same
    viz_figs.text_trialtype = text(.5, 1, ['Panel Loop: ' run_obj.loop_type_str ' | Opto Type: ' run_obj.opto_type] , 'FontSize', 12, 'Interpreter', 'none'); %same
    viz_figs.text_optostatus = text(0, .4, ['Opto status: ']  , 'FontSize', 12, 'Interpreter', 'none'); %same
    viz_figs.accumx_ax = subtightplot(7,7,[8:11], [.05 .05], [.1, .1], [.1, .1]);
    viz_figs.fwd_ax = subtightplot(7,7,[15:18], [.05 .05], [.1, .1], [.1, .1]);
    viz_figs.ang_ax = subtightplot(7,7,[22:25], [.05 .05], [.1, .1], [.1, .1]);
    viz_figs.fwd_histo = subtightplot(7,7,[29:32], [.05 .05], [.1, .1], [.1, .1]);
    viz_figs.ang_histo = subtightplot(7,7,[36:39], [.05 .05], [.1, .1], [.1, .1]);
    viz_figs.fwd_raster = subtightplot(7,7,[12:14,19:21], [.05 .05], [.1, .1], [.1, .1]); 
    viz_figs.ang_raster = subtightplot(7,7,[26:28, 33:35], [.05 .05], [.1, .1], [.1, .1]); 
    viz_figs.trial_dur = subtightplot(7,7,[40:42, 47:49], [.05 .05], [.1, .1], [.1, .1]); 
end
%%%%%

session_id = run_obj.session_id;

% Set number of trial types
run_obj.trial_type_count = num_trial_types(run_obj.loop_type_str);

experiment_list = cell(1, run_obj.num_trials);

opto_list = cell(1, run_obj.num_trials);
if run_obj.opto_on == 1
    % make trial type list
    exp_string = run_obj.experiment_type;
    experiment_list(1:run_obj.num_trials_pre) = {'freewalk'};
    experiment_list(run_obj.num_trials_pre+1:run_obj.num_trials_pre+run_obj.num_trials_exp) = {exp_string};
    experiment_list(run_obj.num_trials_pre+run_obj.num_trials_exp+1:run_obj.num_trials_pre+run_obj.num_trials_exp+run_obj.num_trials_post) = {'freewalk'};

    opto_string = run_obj.opto_type;
    opto_list(:) = {opto_string};
else
    experiment_list(1:end) = {'freewalk'};
    opto_list(1:end) = {'none'};
end

% Make runobject folder
if(~exist([run_obj.experiment_ball_dir '\runobj\'], 'dir'))
    mkdir([run_obj.experiment_ball_dir '\runobj\']);
end

% Save run_obj first
save([run_obj.experiment_ball_dir '\runobj\' datestr(now, 'yyyy_mmdd_HH_MM_SS') '_sid_' num2str(session_id) '_runobj.mat'], 'run_obj');

fwd_histogram = [];
ang_histogram = [];
panel_histogram = [];

%I'm adding some variables to store multi-trial data for the virtual hallway-MB 20190823
if run_obj.experiment_number == 7
    ang_all_trials = [];
    trial_dur_all_trials = [];
    fwd_vel = {};
    ang_vel = {};
    panels_y = {};
    probe_Status = [];
    empty_Trials = [];
%%%%%

%I'm adding some lines to define the probe trials - MB 20190821
    probePercent = run_obj.probe_percentage;
    probeNum = round(task_cnt*(probePercent/100));
    trials = [1:task_cnt];
    probeTrials = datasample(trials,probeNum,'Replace',false);
%%%%

%I'm adding 3 empty trials per session to see the animal's behavior without
%visual stimuli - MB 20190826
    nonProbeTrials = setdiff(trials,probeTrials);
    if probePercent ~= 100
        emptyTrials = datasample(nonProbeTrials,3,'Replace',false);
    elseif probePercent == 100
        emptyTrials = 0;
    end
end    
%%%%

% For each trial:
for i = 1:task_cnt
    exp_type = run_obj.loop_type_str;    
    
    cur_task = select_trial(exp_type, i, task_cnt);        

    cur_trial_corename = [cur_task '_' datestr(now, 'yyyymmdd_HHMMSS') '_sid_' num2str(session_id) '_tid_' num2str(i-1)];  

        %I'm changing this to run with time for every experiment other than the virtual hallway, but run with distance for the virtual hallway -MB 20190806
    if run_obj.experiment_number ~= 7 & run_obj.experiment_number ~= 8
        [trial_bdata, trial_time] = run_trial(i, cur_task, run_obj, scanimage_client_skt, cur_trial_corename );
        [fwd_histogram, ang_histogram, panel_histogram] = display_trial( cur_task, i-1, run_obj, trial_time, trial_bdata, viz_figs, fwd_histogram, ang_histogram, panel_histogram);
    elseif run_obj.experiment_number == 8
        [trial_bdata, trial_time] = run_wind_trial(i, cur_task, run_obj, scanimage_client_skt, cur_trial_corename );
        [fwd_histogram, ang_histogram, panel_histogram] = display_trial( cur_task, i-1, run_obj, trial_time, trial_bdata, viz_figs, fwd_histogram, ang_histogram, panel_histogram);
    else
        if (probePercent < 100 & sum(emptyTrials == i) == 1) %if this is an empty trial
           [trial_bdata, trial_time] = run_empty_trial(i, cur_task, run_obj, scanimage_client_skt, cur_trial_corename);
           disp('This is an empty trial')
        else %if this is an opto or probe trial
            [trial_bdata, trial_time] = run_trial_vHallway(i, cur_task, run_obj, scanimage_client_skt, cur_trial_corename,sum(probeTrials == i));            
        end
        [fwd_histogram, ang_histogram, trial_dur_all_trials,fwd_vel,ang_vel,panels_y,probe_Status,empty_Trials] = display_trial_vhallway( cur_task, i-1, run_obj, trial_time, trial_bdata, viz_figs, fwd_histogram, ang_histogram, trial_dur_all_trials, sum(probeTrials == i),fwd_vel,ang_vel,panels_y,probe_Status,empty_Trials,sum(emptyTrials == i));
    end
    
    
    % Save data              
    cur_trial_file_name = [ run_obj.experiment_ball_dir '\bdata_' cur_trial_corename '.mat' ];
    if run_obj.experiment_number == 7
        save( cur_trial_file_name, 'trial_bdata', 'trial_time', 'probeTrials', 'emptyTrials' );
    else
        save(cur_trial_file_name, 'trial_bdata', 'trial_time')
    end
        %I've added to the data saved the probeTrials and emptyTrials - MB
    %20190826

    % wait for an inter-trial period
    if( i < task_cnt )
        disp(['Finished with trial: ' num2str(i-1) '. Waiting for ' num2str(run_obj.inter_trial_t) ' seconds till next trial']);
        pause(run_obj.inter_trial_t);
    end
end    

if(run_obj.using_2p == 1)
    fprintf(scanimage_client_skt, 'END_OF_SESSION');
    fclose(scanimage_client_skt);
end

Panel_com('all_off');

% Save viz figures       
saveas( viz_figs.data_fig, [run_obj.experiment_ball_dir '\trial_figure_' datestr(now, 'yyyy_mmdd_HH_MM_SS') '_sid_' num2str(session_id) '.fig'] );

% Update session id    
set(run_obj.session_id_hdl, 'String', num2str(session_id+1));
disp('Trials complete.');

end

%% This function helps determine trial type
function [trial] = select_trial(task, trial_num, total_trials)
trial = '';
if ( strcmp(task, 'Closed_Loop') == 1 )
    trial = 'ClosedLoop';
elseif ( strcmp(task, 'Open_Loop') == 1 )
    trial = 'OpenLoop';
elseif ( strcmp(task, 'Optokinetic') == 1 )
    trial_types = {'OpenLoopRight', 'OpenLoopLeft'};
    choice = randi(2,1);
    trial = trial_types{choice};
elseif ( strcmp(task, 'Off') == 1 )
    trial = 'Off';
elseif ( strcmp(task, 'Closed_Loop_X_Open_Loop_Y') == 1 )
    trial = 'Closed_Loop_X_Open_Loop_Y';
elseif ( strcmp(task, 'Closed_Loop_X_Closed_Loop_Y') == 1 )
    trial = 'Closed_Loop_X_Closed_Loop_Y';
end

end

function [number] = num_trial_types(task)
number = 1;
if ( strcmp(task, 'Closed_Loop') == 1 )
    number = 1;
elseif ( strcmp(task, 'Open_Loop') == 1 )
    number = 1;
elseif ( strcmp(task, 'Off') == 1 )
    number = 1;
elseif ( strcmp(task, 'Optokinetic') == 1 )
    number = 2;
elseif ( strcmp(task, 'Closed_Loop_X_Open_Loop_Y') == 1 )
    number = 1;
elseif ( strcmp(task, 'Closed_Loop_X_Closed_Loop_Y') == 1 )
    number = 1;
end
end
