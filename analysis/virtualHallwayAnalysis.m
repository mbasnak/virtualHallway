%Analysis code for the virtual hallway with reward experiment.

%Things to look at:
%1)forward velocity around opto trigger for the training trials
%2)angular velocity around opto trigger for the training trials
%3)progression of forward velocity across various training trials
%4)forward and angular velocities close to where the reward would be in
%test trials.
%5)trajectories
%6)duration of trials vs trial number
%7)heatmaps for velocity with the opto trigger
%8)difference between training and probes


close all; clear all;

% prompt the user to select the file to open and load it.
cd 'Z:\Wilson Lab\Mel\FlyOnTheBall\data\Experiment16'
%[file,path] = uigetfile();
% load([path,file]);
dirName = uigetdir();
cd(dirName)
fileNames = dir('*.mat');

prompt = 'What session would you like to analyse? ';
sid = input(prompt);

%load data from all trials of a specific session.
for i = 1:length(fileNames)
    if regexp(fileNames(i).name,strcat('sid_',num2str(sid))) > 0
        rawData{i} = load(strcat(fileNames(i).folder,'\',fileNames(i).name));
    end
end
%remove empty cells
rawData = rawData(~cellfun('isempty',rawData));

% Define Ni-Daq channels ID
%Prompt the user to ask which room the data was collected in
list = {'Jenny-2P','Jenny-Behavior','Mel-2P','Mel-Behavior'};
[indx] = listdlg('ListString',list);
room = list(indx);

NiDaqChannels = loadSettings(room{1,1}); %load the appropriate NiDaq settings

headingFly = NiDaqChannels.headingFly;
yFly = NiDaqChannels.yFly;
xFly = NiDaqChannels.xFly;
xFlyGain = NiDaqChannels.xFlyGain;
xPanels = NiDaqChannels.xPanels;
yPanels = NiDaqChannels.yPanels;
PanelStatus = NiDaqChannels.PanelStatus;
OptoTrigger = NiDaqChannels.OptoTrigger;

samplingRate = 4000;

%% Trial length vs trial number

figure,

for i = 1:length(rawData)
    trialDur(i) = size(rawData{1,i}.trial_bdata,1);
end
trialNum = [1:length(rawData)];

subplot(1,2,1)
plot(trialNum,trialDur/samplingRate,'ko')
xlabel('Trial number'); ylabel('Trial duration (s)');

subplot(1,2,2)
boxplot(trialDur/4000)
title('Distribution of trial duration')
set(gca,'XTick',[])

%for when I have the probeTrials and emptyTrials
probeTrials = rawData{1,1}.probeTrials;
emptyTrials = rawData{1,1}.emptyTrials;
optoTrials = setdiff(trialNum,[probeTrials,emptyTrials]);

% subplot(1,2,1)
% plot(trialNum(probeTrials),trialDur(probeTrials)/samplingRate,'ko')
% hold on
% plot(trialNum(emptyTrials),trialDur(emptyTrials)/samplingRate,'bo')
% plot(trialNum(optoTrials),trialDur(optoTrials)/samplingRate,'ro')
% xlabel('Trial number'); ylabel('Trial duration (s)');
% legend('Probe trials', 'Empty trials', 'Opto trials');
% 
% subplot(1,2,2)
% boxplot(trialDur/4000)
% title('Distribution of trial duration')
% set(gca,'XTick',[])

saveas(gcf,[dirName,'\TrialDurVsTrialNum.png'])

%% Subset acquisition of x and y pos, as well as FicTrac data

for i = 1:length(rawData)
    
    Data = rawData{1,i}.trial_bdata;
    
    data.xPanelVolts =  Data (:,xPanels); 
    VOLTAGE_RANGE_x = 10;
    maxValX =  96 ;

    data.yPanelVolts =  Data (:, yPanels);
    VOLTAGE_RANGE_y = 10;
    maxValY = 92; %both virtual hallways have 92 y dimensions
    
    %FicTrac data
    data.ficTracAngularPosition = Data ( : , headingFly); 
    data.ficTracIntx = Data ( : , xFly); 
    data.ficTracInty = Data ( : , yFly); 

    sizeBall = 9;
    [smoothed{i}] = singleTrialVelocityAnalysis9mm(data,samplingRate);
    [forwardVel{i}, accumulatedx{i}] = ficTracSignalDecoding(data.ficTracIntx, samplingRate , 50, 10);
    %The difference between the 2 methods to obtain the velocity is pretty
    %big, so I need to double check both well.
end


%% Plotting velocities


%Downsampling them to the minimum length

for i = 1:length(smoothed)
    sizes(i) = length(smoothed{1,i}.xVel);   
end
minLength = min(sizes);

for i = 1:length(smoothed)
    downsampled(i,:) = resample(smoothed{1,i}.xVel,minLength,length(smoothed{1,i}.xVel));   
end

figure,
imagesc(downsampled)
c = colorbar;
cLabel = ylabel(c, 'Forward velocity (mm/s)');     
%set(cLabel,'Rotation',-90);
xlabel('Time');ylabel('Trial number');
saveas(gcf,[dirName,'\FwdVelRaster.png'])


%In the next figure I'm plotting the forward velocity for each trial but
%adding an arbitrary spacing between them to be able to compare them
figure,
for i = 1:length(smoothed)
    time = linspace(0,length(smoothed{1,i}.xVel)/samplingRate,length(smoothed{1,i}.xVel));
    plot(time,smoothed{1,i}.xVel+i+5);
    hold on
end
xlabel('Time');
ylabel('Forward velocity (mm/s');
saveas(gcf,[dirName,'\FwdVelSingleTrials.png'])


%separating by probe vs non probe
figure,
for i = 1:length(smoothed)
    time = linspace(0,length(smoothed{1,i}.xVel)/25,length(smoothed{1,i}.xVel));
    if any(probeTrials == i)
        plot(time,smoothed{1,i}.xVel+i+5,'k');
    elseif any(emptyTrials == i)
        plot(time,smoothed{1,i}.xVel+i+5,'b');
    else
        plot(time,smoothed{1,i}.xVel+i+5,'r');
    end
        hold on
end
xlabel('Time (s)'); ylabel('Forward velocity (mm/s)');

%% Plot the velocities

figure,
subplot(2,1,1)
plot(smoothed.xVel,'k')
hold on
downsampledTrigger = downsample(rawData(:,OptoTrigger),samplingRate/25);
plot(downsampledTrigger,'r')
ylabel('Forward velocity') ; xlabel('Time');

subplot(2,1,2)
plot(smoothed.angularVel,'k')
hold on
downsampledTrigger = downsample(rawData(:,OptoTrigger),samplingRate/25);
plot(downsampledTrigger,'r')
ylabel('Angular velocity') ; xlabel('Time');


%% 2D trajectories

%Corrected trajectory: this is the actual trajectory the fly took during
%the block
[posx2,posy2]=FlyTrajectory(smoothed.Intx,smoothed.Inty,smoothed.angularPosition);
time = linspace(1,length(trial_time)/samplingRate,length(posx2));

figure, scatter(posx2,posy2,1,time);
h2 = colorbar
title(h2, 'Time (s)')
axis equal
axis tight
title('Corrected 2D trajectory');

