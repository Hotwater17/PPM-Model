function lut_corrected = lut_correct(cfg, lut, traces, clk, codes)
disp("Performing LUT correction...");

%% Calculate code for cycle
stat_codes_avg = cell(height(lut.lut_cycle_values), 48);
stat_codes_std = cell(height(lut.lut_cycle_values), 48);
stat_avg_diff = cell(height(lut.lut_cycle_values), 48);
stat_code_round = cell(height(lut.lut_cycle_values), 48);
stat_code_floor = cell(height(lut.lut_cycle_values), 48);
stat_code_ceil = cell(height(lut.lut_cycle_values), 48);
stat_round_diff = cell(height(lut.lut_cycle_values), 48);
for ii=1:height(lut.lut_cycle_values)
    for jj=1:width(lut.lut_cycle_values)
        stat_codes_avg{ii, jj} = 255*((mean(codes.energies_cycle{ii,jj}))/(cfg.vdd*cfg.tclk*2))/cfg.i_max;
        stat_codes_std{ii, jj} = 255*((std(codes.energies_cycle{ii,jj}))/(cfg.vdd*cfg.tclk*2))/cfg.i_max;
        stat_avg_diff{ii,jj} = stat_codes_avg{ii,jj} - lut.lut_cycle_values(ii,jj);
        stat_code_round{ii,jj} = round(stat_codes_avg{ii,jj});
        stat_code_floor{ii,jj} = floor(stat_codes_avg{ii,jj});
        stat_code_ceil{ii,jj} = ceil(stat_codes_avg{ii,jj});
        stat_round_diff{ii,jj} = stat_code_round{ii,jj} - lut.lut_cycle_values(ii,jj);
        % ldo_energy(ii) = i_avg(ii)*cfg.vdd*cfg.tclk;
        %i_avg = energy/(cfg.vdd*cfg.tclk);
        %code = round((i_avg/cfg.i_max)*255);
        %energy = i_avg*cfg.vdd*cfg.tclk (of LDO clock)
        %code = imax
        %code(i) = (current_trace(index)/cfg.i_max)*255;
    end
end
stat_1st_codes_avg = cell(height(lut.lut_cycle_values), height(lut.lut_cycle_values));
stat_1st_codes_std = cell(height(lut.lut_cycle_values), height(lut.lut_cycle_values));
%stat_1st_code_round = cell(height(lut.lut_cycle_values), height(lut.lut_cycle_values));
% Calculate 1st cycle codes
for ii=1:height(lut.lut_cycle_values)
    for jj=1:height(lut.lut_cycle_values)
        stat_1st_codes_avg{ii, jj} = 255*((mean(codes.energy_1st_cycle{ii,jj}))/(cfg.vdd*cfg.tclk*2))/cfg.i_max;
        stat_1st_codes_std{ii, jj} = 255*((std(codes.energy_1st_cycle{ii,jj}))/(cfg.vdd*cfg.tclk*2))/cfg.i_max;
        stat_1st_code_round{ii,jj} = round(stat_1st_codes_avg{ii,jj}+stat_1st_codes_std{ii,jj}/2);
    end
end

lut_corrected.lut_code_avg = stat_codes_avg;
lut_corrected.stat_code_round = stat_code_round;
lut_corrected.stat_code_floor = stat_code_floor;
lut_corrected.stat_code_ceil = stat_code_ceil;
lut_corrected.stat_1st_code_round = stat_1st_code_round;

end