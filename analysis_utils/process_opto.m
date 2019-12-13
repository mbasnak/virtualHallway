function opto = process_opto(rawData)
%% REMEMBER
% Pattern x=1 starts eastward most.
% Pattern goes counterclockwise thereafter.
%5 panels = 75;
%7 panels = 105;
rounded_opto = round(rawData);


settings = sensor_settings;
%dt = settings.sampRate/settings.sensorPollFreq;
%x = floor(length(rounded_opto)/dt);
n = floor(settings.sampRate/settings.sensorPollFreq);
%cut_length = x*dt;
%smoothedData_downsampled = squeeze(mean(reshape(rounded_opto(1:cut_length), [dt, x])));
smoothedData_downsampled = downsample(rounded_opto, n);
opto = smoothedData_downsampled;