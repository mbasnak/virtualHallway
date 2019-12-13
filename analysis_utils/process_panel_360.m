%I'm commenting this code and changing it to make sense with my set-up - MB
%20190808

function [fr, angle] = process_panel_360(rawData, frames)

% Initial variables
settings = sensor_settings;
maxVal = 10;
minVal = 0;
%initialAngle = -15; %I think this means how many pixels from the center her x=1 (0V) is.
initialAngle = -3; %my x=1 positon is 3 pixels to the rigtof the animal
barWidth = 2;
voltsPerStep = (maxVal-minVal)./(frames-1); %how much voltage corresponds to a pixel movement

rate = 2*(50/settings.sampRate); %I don't know why this would be the rate
[kb, ka] = butter(2,rate);

% Set limits on voltage; then filter
rawData(rawData < minVal) = minVal; %remove voltages under 0 if there was any
rawData(rawData > maxVal) = maxVal; %remove voltages over 10 if there was any

smoothedData = filtfilt(kb, ka, rawData); %filter the data.

% Calculate the frame number (round to nearest integer), calculate the
% pixel angle of the bar given the grame number.
fr = round((smoothedData - minVal)./voltsPerStep);
pixelAngle = 360./96;
arenaAngle = frames*pixelAngle; %this is just 360
%angle = (initialAngle-((fr-1)+barWidth/2).*pixelAngle); % accounts for the bar width
%I'm changing the above to something that I think is working better for me
%-MB 20190809
angle = (fr+1+initialAngle).*pixelAngle;


% Wrap to 180 
angle = wrapTo180(angle);
if arenaAngle < 360
    halfArena = arenaAngle./2;
    indexOver = angle < -halfArena;
    angle = angle + indexOver.*arenaAngle;
end

%% 4-5-19 downsampling
settings = sensor_settings;

n = floor(settings.sampRate/settings.sensorPollFreq);

angle_downsampled = downsample(angle, n);
angle = angle_downsampled;

fr_downsampled = downsample(fr, n);
fr = fr_downsampled;