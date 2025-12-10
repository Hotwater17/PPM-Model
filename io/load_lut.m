function lut = load_lut(cfg, lut_type)

disp("Loading LUT...");
%lut_file = cfg.lut_dir+"/"+cfg.lut_filename+".csv"


lut_cycle_file = cfg.lut_dir+"/"+cfg.lut_filename+".csv"
design = 'INSTR'
opts = detectImportOptions(lut_cycle_file);
opts = setvartype(opts, design, 'string');
lut_cycle_inputs = table2array(readtable(lut_cycle_file, opts));
lut_cycle_instr = lut_cycle_inputs(:,1);


lut_cycle_iter = str2double(lut_cycle_inputs(:,2));
n_cycles_max = 48;
n_instr = height(lut_cycle_instr)

lut_cycle_values = zeros(n_instr, n_cycles_max);
for kk = 1:n_instr
    for ii = 1:n_cycles_max
        lut_cycle_values(kk, ii) = str2double(lut_cycle_inputs(kk, 2+ii));
    end
end
%lut_cycle_values(3,:) = ones(1,48).*32;
%lut_cycle_values(4,:) = ones(1,48).*55;
%lut_cycle_values(4,1:5) = 26;

lut.lut_cycle_iter = lut_cycle_iter;
lut.lut_cycle_values = lut_cycle_values;
lut.lut_instr = lut_cycle_instr;
lut.n_instr = n_instr;
lut.n_cycles_max = n_cycles_max;



end