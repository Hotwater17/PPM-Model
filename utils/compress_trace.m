%% Compress trace file
function [t_compressed, y_compressed] = compress_trace(t, y, margin)
     % Find indices where the value changes
    dy = diff(y);
    change_idx = find(dy ~= 0) + 1;  % +1 since diff shifts index

    keep_idx = [];
    % Add margin samples before and after each change
    for ii = 1:length(change_idx)
        idx_range = (change_idx(ii)-margin:(change_idx(ii)+margin));
        keep_idx = [keep_idx idx_range];
    end
    %Clip indices
    keep_idx = unique(keep_idx);

    %Get time indices
    
    y_compressed = [y(1); y(keep_idx); y(end)];
    t_compressed = [t(1); t(keep_idx); t(end)];

end