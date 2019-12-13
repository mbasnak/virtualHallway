function logDaqData(fid,evt,inds_to_keep)
    % make matrix for data to be written in
    data = [evt.TimeStamps, evt.Data]';
    
    % keep only the inds specified (if specified)
    if exist('inds_to_keep','var')
        data = data(inds_to_keep,:);
    end
    
    % precision is only single
    fwrite(fid,data,'double');
end