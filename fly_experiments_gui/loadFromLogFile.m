function [daq_data] = loadFromLogFile(log_file_path,n_chan)
    log_file_id = fopen(log_file_path,'r');
    daq_data  = fread(log_file_id,'double');
    daq_data  = reshape(daq_data,n_chan+1,[]);
    daq_data  = daq_data(2:end,:);
end