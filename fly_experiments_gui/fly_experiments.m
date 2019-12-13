function varargout = fly_experiments(varargin)
%FLY_EXPERIMENTS MATLAB code file for fly_experiments.fig
%      FLY_EXPERIMENTS, by itself, creates a new FLY_EXPERIMENTS or raises the existing
%      singleton*.
%
%      H = FLY_EXPERIMENTS returns the handle to a new FLY_EXPERIMENTS or the handle to
%      the existing singleton*.
%
%      FLY_EXPERIMENTS('Property','Value',...) creates a new FLY_EXPERIMENTS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to fly_experiments_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      FLY_EXPERIMENTS('CALLBACK') and FLY_EXPERIMENTS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in FLY_EXPERIMENTS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fly_experiments

% Last Modified by GUIDE v2.5 12-Dec-2019 14:13:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fly_experiments_OpeningFcn, ...
                   'gui_OutputFcn',  @fly_experiments_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before fly_experiments is made visible.
function fly_experiments_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for fly_experiments
handles.output = hObject;

% Prompt for an experiment directory
expdname = uigetdir('Z:\Wilson Lab\Mel\FlyOnTheBall\data\', 'Please chose an experiment directory.');
handles.experiment_dir = expdname;

get_experiment_folder_ready(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = fly_experiments_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% --- Executes on button press in experiment_dir_button.
function experiment_dir_button_Callback(hObject, eventdata, handles)
% Prompt for an experiment directory
expdname = uigetdir('Z:\Wilson Lab\Mel\FlyOnTheBall\data\', 'Please chose an experiment directory.');
handles.experiment_dir = expdname;

get_experiment_folder_ready(hObject, handles);

function get_experiment_folder_ready(hObject, handles)
% Prompt for an experiment name
handles.expname = inputdlg('Provide an experiment name (e.g. 60D05_6f)', 'Experiment Name');

% Get the date and time
handles.date = datetime('today','Format', 'yyyyMMdd');
handles.time = datetime('now', 'Format', 'HH:mm');

% Make the folders and set the dname
ball_directory = [handles.experiment_dir '\' char(datetime('today','Format', 'yyyyMMdd')) '_' char(handles.expname) '\ball'];
twop_directory = [handles.experiment_dir '\' char(datetime('today','Format', 'yyyyMMdd')) '_' char(handles.expname) '\2p'];
if ~exist(ball_directory)
    mkdir(ball_directory);
    mkdir(twop_directory);
else
    answer = questdlg('Did you want to add to an existing fly?', 'Experiment Name Taken', 'Yes', 'No: new fly', 'Cancel');
    switch answer
        case 'Yes'
        case 'No: new fly'
            get_experiment_folder_ready(hObject, handles)
            return
        case 'Cancel'
            return
    end
end

dname = ball_directory;

ghandles = guihandles(hObject);
set(ghandles.experiment_dir_edit, 'String', dname);
handles.experiment_ball_dir = dname;
% Update handles structure
guidata(hObject, handles);

function experiment_dir_edit_Callback(hObject, eventdata, handles)

% --- Executes on button press in run_button.
function run_button_Callback(hObject, eventdata, handles)
ghandles = guihandles(hObject);

% experiment variables
run_obj.date = handles.date;
run_obj.time = handles.time;
run_obj.expname = handles.expname;
run_obj.experiment_dir = handles.experiment_dir;
run_obj.experiment_ball_dir = handles.experiment_ball_dir;
run_obj.session_id = str2num(get(ghandles.session_id_edit, 'String'));
run_obj.session_id_hdl = ghandles.session_id_edit;
%%%%I'm adding this for the percentage of probe trials - MB 20190822
run_obj.probe_percentage = str2num(get(ghandles.probe_percentage_edit, 'String'));
run_obj.probe_percentage_hdl = ghandles.probe_percentage_edit;
%%%%

% trial variables
run_obj.num_trials = str2num(get(ghandles.num_trials, 'String'));
run_obj.trial_t = str2num(get(ghandles.trial_length_edit, 'String'));
run_obj.inter_trial_t = str2num(get(ghandles.inter_trial_period_edit, 'String'));

% optogenetics variables STIMV2

    
run_obj.experiment_number = get(ghandles.experiment_number, 'Value');
if run_obj.experiment_number == 3
    run_obj.opto_on = 1;
else
    run_obj.opto_on = 0;
end

run_obj.opto_type = num2str(run_obj.experiment_number);

run_obj.bar_jump_time = str2num(get(ghandles.bar_jump_time, 'String'));
run_obj.hold_time = str2num(get(ghandles.hold_time, 'String'));
run_obj.goal_change = str2num(get(ghandles.goal_change, 'String'));
run_obj.goal_window = str2num(get(ghandles.goal_window, 'String'));
run_obj.pre_training = str2num(get(ghandles.pre_training_time, 'String'));
run_obj.training = str2num(get(ghandles.training_time, 'String'));

if(run_obj.trial_t < (run_obj.pre_training + run_obj.training))
    errordlg('Make trial time greater than training and pretraining times.');
    return;
end

% panel variables
run_obj.number_frames = 96;
run_obj.pattern_number = str2num(get(ghandles.pattern_number_edit, 'String'));
run_obj.function_number = str2num(get(ghandles.function_number, 'String'));
run_obj.start_frame = str2num(get(ghandles.start_frame, 'String'));
run_obj.loop_type = get(ghandles.panels_loop,'Value');
loop_types = get(ghandles.panels_loop, 'String');
run_obj.loop_type_str = loop_types{run_obj.loop_type};

% 2p variable
run_obj.using_2p = get(ghandles.using_2p,'Value');

begin_trials(run_obj);
guidata(hObject, handles);

function num_trials_Callback(hObject, eventdata, handles)
ghandles = guihandles(hObject);
num_trials_pre = str2num(get(ghandles.num_trials_pre, 'String'));
num_trials_exp = str2num(get(ghandles.num_trials_exp, 'String'));
num_trials = str2num(get(ghandles.num_trials, 'String'));
set(ghandles.num_trials_post, 'String', num2str(num_trials-num_trials_pre-num_trials_exp));

% function inter_trial_period_edit_Callback(hObject, eventdata, handles)

function num_trials_pre_Callback(hObject, eventdata, handles)
ghandles = guihandles(hObject);
num_trials_pre = str2num(get(ghandles.num_trials_pre, 'String'));
num_trials_exp = str2num(get(ghandles.num_trials_exp, 'String'));
num_trials = str2num(get(ghandles.num_trials, 'String'));
set(ghandles.num_trials_post, 'String', num2str(num_trials-num_trials_pre-num_trials_exp));

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function num_trials_pre_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function num_trials_exp_Callback(hObject, eventdata, handles)
ghandles = guihandles(hObject);
num_trials_pre = str2num(get(ghandles.num_trials_pre, 'String'));
num_trials_exp = str2num(get(ghandles.num_trials_exp, 'String'));
num_trials = str2num(get(ghandles.num_trials, 'String'));
set(ghandles.num_trials_post, 'String', num2str(num_trials-num_trials_pre-num_trials_exp));

% --- Executes during object creation, after setting all properties.
function num_trials_exp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function num_trials_post_Callback(hObject, eventdata, handles)
ghandles = guihandles(hObject);
num_trials_pre = str2num(get(ghandles.num_trials_pre, 'String'));
num_trials_exp = str2num(get(ghandles.num_trials_exp, 'String'));
num_trials_post = str2num(get(ghandles.num_trials_post, 'String'));
set(ghandles.num_trials, 'String', num2str(num_trials_post+num_trials_pre+num_trials_exp));

% --- Executes during object creation, after setting all properties.
function num_trials_post_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in appetitive.
function appetitive_Callback(hObject, eventdata, handles)

% --- Executes on button press in aversive.
function aversive_Callback(hObject, eventdata, handles)

% --- Executes on selection change in panels_loop.
function panels_loop_Callback(hObject, eventdata, handles)
ghandles = guihandles(hObject);
loop_type = get(ghandles.panels_loop,'Value');
all_loop_types = get(ghandles.panels_loop, 'String');
loop_type_str = all_loop_types{loop_type};
if ( strcmp(loop_type_str, 'Off') == 1 )
    set(ghandles.pattern_number_edit, 'String', 1);
end

function pattern_number_edit_Callback(hObject, eventdata, handles)

function function_number_Callback(hObject, eventdata, handles)

function start_frame_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function session_id_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to session_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function session_id_edit_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to experiment_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns experiment_number contents as cell array
%        contents{get(hObject,'Value')} returns selected item from experiment_number

%I'm adding this for the percentage of probe trials = MB 20190822
function probe_percentage_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to session_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%%%%%



% --- Executes during object creation, after setting all properties.
function trial_length_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trial_length_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function num_trials_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_trials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function inter_trial_period_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inter_trial_period_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function panels_loop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to panels_loop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function pattern_number_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pattern_number_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function start_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function experiment_dir_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to experiment_dir_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function function_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to function_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in opto_off.
function opto_off_Callback(hObject, eventdata, handles)
% hObject    handle to opto_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in using_2p.
function using_2p_Callback(hObject, eventdata, handles)
% hObject    handle to using_2p (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function goal_window_Callback(hObject, eventdata, handles)
% hObject    handle to goal_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of goal_window as text
%        str2double(get(hObject,'String')) returns contents of goal_window as a double


% --- Executes during object creation, after setting all properties.
function goal_window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to goal_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function goal_change_Callback(hObject, eventdata, handles)
% hObject    handle to goal_change (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of goal_change as text
%        str2double(get(hObject,'String')) returns contents of goal_change as a double


% --- Executes during object creation, after setting all properties.
function goal_change_CreateFcn(hObject, eventdata, handles)
% hObject    handle to goal_change (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pre_training_time_Callback(hObject, eventdata, handles)
% hObject    handle to pre_training_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pre_training_time as text
%        str2double(get(hObject,'String')) returns contents of pre_training_time as a double


% --- Executes during object creation, after setting all properties.
function pre_training_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pre_training_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function training_time_Callback(hObject, eventdata, handles)
% hObject    handle to training_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of training_time as text
%        str2double(get(hObject,'String')) returns contents of training_time as a double


% --- Executes during object creation, after setting all properties.
function training_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to training_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bar_jump_time_Callback(hObject, eventdata, handles)
% hObject    handle to bar_jump_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bar_jump_time as text
%        str2double(get(hObject,'String')) returns contents of bar_jump_time as a double


% --- Executes during object creation, after setting all properties.
function bar_jump_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bar_jump_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stimv2.
function stimv2_Callback(hObject, eventdata, handles)
% hObject    handle to stimv2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stimv2



function hold_time_Callback(hObject, eventdata, handles)
% hObject    handle to hold_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hold_time as text
%        str2double(get(hObject,'String')) returns contents of hold_time as a double


% --- Executes during object creation, after setting all properties.
function hold_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hold_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in experiment_number.
function experiment_number_Callback(hObject, eventdata, handles)
% hObject    handle to experiment_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns experiment_number contents as cell array
%        contents{get(hObject,'Value')} returns selected item from experiment_number


% --- Executes during object creation, after setting all properties.
function experiment_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to experiment_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


