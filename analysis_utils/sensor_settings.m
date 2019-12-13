function settings = sensor_settings

% Acquisition params
settings.sampRate = 4000;

% Processing settings
settings.cutoffFreq = 100;
settings.aiType = 'SingleEnded';
%settings.cutoffFreq_disp = 50;
%settings.cutoffFreq_vel = 15;
settings.sensorPollFreq = 50; 

