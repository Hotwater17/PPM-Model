function traces = load_traces(cfg, n_repeats)

disp("Loading trace data...");

current_file = cfg.input_dir+"/"+cfg.bmark+"_TRIMMED.csv"
inputs = table2array(readtable(current_file));

time_trace = inputs(:,1);
current_trace = inputs(:,2);
end_time = time_trace(length(time_trace));


instr_file = cfg.input_dir+"/"+cfg.bmark+"_NEW_instr.csv"
opts = detectImportOptions(instr_file);
opts = setvartype(opts, 'INSTR', 'string');
instr_inputs = table2array(readtable(instr_file, opts));
instr_time = str2double(instr_inputs(:,1));
instr_vect = instr_inputs(:,2);

%Repeat instruction, current and time vectors n_repeats times

for ii = 2:n_repeats
    "Repeating:"+ii
    instr_vect = [instr_vect; instr_inputs(:,2)];
    instr_time = [instr_time; str2double(instr_inputs(:,1)) + end_time*(ii-1)];
    time_trace = [time_trace; inputs(:,1) + end_time*(ii-1)];
    current_trace = [current_trace; inputs(:,2);];
end
end_time = time_trace(length(time_trace));

instr_lut_indices = [];

traces.time_trace = time_trace;
traces.current_trace = current_trace;
traces.end_time = end_time;
traces.instr_vect = instr_vect;
traces.instr_time = instr_time;
traces.vect_len = length(traces.current_trace) -90*cfg.tclk/cfg.twindow;
