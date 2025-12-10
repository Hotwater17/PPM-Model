function instr_cycle_codes = calc_instr_cycle_codes(cfg, traces, clk, lut, round_type, corr)

disp("Calculating instruction cycle codes...");
instr_lut_indices = [];
bmark_code = [];
bmark_cycle = [];

for ii = 1:length(traces.instr_vect)
    %Get LUT index: Compare strings, find non-zero element in vector. 
    instr_lut_indices(ii) = find(strcmp(traces.instr_vect(ii), lut.lut_instr));
    bmark_code(ii) = lut.lut_cycle_values(instr_lut_indices(ii));
    bmark_cycle(ii) = lut.lut_cycle_iter(instr_lut_indices(ii));

end

%% Predicted code actuation, averaged for instruction
ninstr_ticks = 100;

act_cycle = traces.vect_len
cycle_trace = ones(1, act_cycle);
code_cycle = ones(1, act_cycle).*28;
instr_trace = [];
instr_code_trace = [];
ninstr_pulse = [];
instr_code = 0;
idx_start_corr = 0;
ll = 0;


%energies = zeros(length(lut.lut_instr), width(lut.lut_cycle_values), 1000);
energies_cycle = cell(length(lut.lut_instr), 48, 1000);
energies_finstr = cell(length(lut.lut_instr),1000);
energies_ldo_accum = cell(length( lut.lut_instr),1000);
energies_cycle_accum = cell(length(lut.lut_instr),1000);
%Save 1st cycle energy according to current and previous instruction
energy_1st_cycle = cell(length(lut.lut_instr),length(lut.lut_instr),100);
%match code with time of trace
for ii = 1:length(traces.instr_time)-1
    loop_percentage(ii, length(traces.instr_time), 10);
    % go through time, match indices when instruction changes, 
    time_start = traces.instr_time(ii);
    time_stop = traces.instr_time(ii+1);
    idx_start = dsearchn(traces.time_trace, time_start);
    idx_stop = dsearchn(traces.time_trace, time_stop);
    code_proactive(idx_start:idx_stop) = bmark_code(ii);
    
    %Here add info about the cycle in trace as well. 
    %This will be used for real-time correction
    cycle_proactive(idx_start:idx_stop) = bmark_cycle(ii);

    % Get the previous clock edge to correct the instr_code_trace 
    %if(ii > 1)
    %    prev_clk_idx = idx_start + get_edges(clk.clk_trace(idx_start-(2*tclk/twindow):idx_start), 0.6, 'r');
    %    get_edges(clk.clk_trace(idx_start-(2*cfg.tclk/cfg.twindow):idx_start), 0.6, 'r')
    %    [prev_clk_idx, idx_start]
    %end
    if(ii > 1)
        idx_start_corr = idx_start - (cfg.tclk/cfg.twindow);
    else 
        idx_start_corr = idx_start;
    end
    %RECALCULATE THIS IN LOOP
    instr_trace(idx_start_corr:idx_stop-1) = traces.instr_vect(ii);
    instr_code_trace(idx_start_corr:idx_stop-1) = instr_lut_indices(ii);

    %1.Make a new instruction pulse in trace at a new index
    ninstr_pulse(idx_start:idx_start+ninstr_ticks) = cfg.vdd;
    ninstr_pulse(idx_start+ninstr_ticks+1:idx_stop) = 0;
    %cycle_trace(idx_start:idx_stop) = bmark_cycle(ii);
    falling_clks = idx_start + get_edges(clk.clk_trace(idx_start:idx_stop), cfg.vdd/2, 'f');
    rising_clks = idx_start + get_edges(clk.clk_trace(idx_start:idx_stop), cfg.vdd/2, 'r');
    clks = idx_start + get_edges(clk.clk_trace(idx_start:idx_stop), cfg.vdd/2, 'r');


    lens(ii) = length(clks);
    
    
    %energy_instr_ldo(ll) = sum(code_cycle(idx_clk_start:idx_clk_stop-1)) * cfg.i_unit_proactive * cfg.twindow * cfg.vdd;
    %Calculate energy per instr
    energy_instr_trace(ii) = sum(traces.current_trace(idx_start:idx_stop-1))* length(clks)*cfg.twindow * cfg.vdd;
    energies_finstr{instr_lut_indices(ii)} = [energies_finstr{instr_lut_indices(ii)}; energy_instr_trace(ii)];
    accum_load = 0;
    accum_ldo = 0;
    for kk = 1:length(clks)-1
        idx_clk_start = clks(kk);
        idx_clk_stop = clks(kk+1);
        cycle_trace(idx_clk_start:idx_clk_stop-1) = kk;
        
        % From LUT file
        if(round_type == "LUT")
            code_cycle(idx_clk_start:idx_clk_stop-1) = lut.lut_cycle_values(instr_lut_indices(ii), kk);
        elseif(round_type == "ROUND")
            code_cycle(idx_clk_start:idx_clk_stop-1) = corr.stat_code_round{instr_lut_indices(ii), kk};
        elseif(round_type == "FLOOR")
            code_cycle(idx_clk_start:idx_clk_stop-1) = corr.stat_code_floor{instr_lut_indices(ii), kk};
        elseif(round_type == "CEIL")
            code_cycle(idx_clk_start:idx_clk_stop-1) = corr.stat_code_ceil{instr_lut_indices(ii), kk};
        end
        %code_cycle(idx_clk_start:idx_clk_stop-1) = lut.lut_cycle_values(instr_lut_indices(ii), kk);
        % From statistical LUT
        %ROUND
        %code_cycle(idx_clk_start:idx_clk_stop-1) = corr.stat_code_round{instr_lut_indices(ii), kk};
        %FLOOR
        %code_cycle(idx_clk_start:idx_clk_stop-1) = corr.stat_code_floor{instr_lut_indices(ii), kk};
        %CEIL
        %code_cycle(idx_clk_start:idx_clk_stop-1) = corr.stat_code_ceil{instr_lut_indices(ii), kk};

        if(round_type ~= "LUT")
            if(kk == 1 &&  (ii > 1))
                code_cycle(idx_clk_start-(cfg.tclk/cfg.twindow):idx_clk_stop-1) = corr.stat_1st_code_round{instr_lut_indices(ii), instr_lut_indices(ii-1)};
            end
        end
        ll = ll + 1;
        % Calculate energy provided by LDO in a clock cycle
        energy_cycle_ldo(ll) = sum(code_cycle(idx_clk_start:idx_clk_stop-1) * cfg.i_unit_proactive) * cfg.twindow* cfg.vdd;
        energy_cycle_trace(ll) = sum(traces.current_trace(idx_clk_start:idx_clk_stop-1))*cfg.twindow * cfg.vdd;
        energy_diff(ll) = energy_cycle_ldo(ll) - energy_cycle_trace(ll);
        accum_load = accum_load + energy_cycle_trace(ll);
        accum_ldo = accum_ldo + energy_cycle_ldo(ll);

        % Assign the first cycle energy to a table according to current and
        % previous instruction

        if((kk == 1) && (ii > 1))
            energy_cycle_trace(ll) = sum(traces.current_trace(idx_clk_start-(cfg.tclk/cfg.twindow):idx_clk_stop-1))*cfg.twindow * cfg.vdd;
            energy_1st_cycle{instr_lut_indices(ii), instr_lut_indices(ii-1)} = [energy_1st_cycle{instr_lut_indices(ii), instr_lut_indices(ii-1)}; energy_cycle_trace(ll)]; 
        end

        % Final energies table
        energies_cycle{instr_lut_indices(ii), kk} = [energies_cycle{instr_lut_indices(ii),kk}; energy_cycle_trace(ll)];
    end
        energies_cycle_accum{instr_lut_indices(ii)} = [energies_cycle_accum{instr_lut_indices(ii)}; accum_load];
        energies_ldo_accum{instr_lut_indices(ii)} = [energies_ldo_accum{instr_lut_indices(ii)}; accum_ldo];
        %Sum up eneriges from all cycles for a given instr
    

end

instr_cycle_codes.energies_cycle = energies_cycle;
instr_cycle_codes.energy_1st_cycle = energy_1st_cycle;
instr_cycle_codes.energy_ldo = energies_ldo_accum;
instr_cycle_codes.code_cycle = code_cycle;
instr_cycle_codes.cycle_trace = cycle_trace;
instr_cycle_codes.instr_trace = instr_trace;
instr_cycle_codes.instr_code_trace = instr_code_trace;

%{
figure(4);
hold on
yyaxis left
plot(clk_trace);
yyaxis right
plot(instr_code_trace);
hold off

figure(5);
hold on
yyaxis left
plot(current_trace);
%plot()
yyaxis right
%plot(cycle_trace, 'red')

%plot(cycle_trace)
plot(code_cycle)
plot(cycle_trace, 'g')
hold off

figure(7);
hold on
plot(energy_cycle_ldo.*tclk, 'b');
plot(energy_cycle_trace.*tclk, 'r');
hold off
figure(8);
plot(current_trace, 'r')
figure(69);
hold on
histogram(energy_cycle_ldo, 'FaceColor', 'b', 'NumBins', 100)
histogram(energy_cycle_trace, 'FaceColor', 'r', 'NumBins', 100)
hold off;
figure(17);
histogram(energy_diff, 'NumBins', 100);
figure(18);
histogram(energies_cycle{3, 1}.*1E12, 'FaceColor', 'b', 'NumBins', 30)
xlabel('Energy [pJ]')
set(gca, 'FontWeight', 'bold', 'FontSize', 12, 'FontName', 'arial')
xline(mean(energies_cycle{3, 1}.*1E12), 'LineWidth', 1)

figure(19);
histogram(energy_1st_cycle{2, 3}.*1E12, 'FaceColor', 'b', 'NumBins', 30)
xlabel('Energy [pJ]')
set(gca, 'FontWeight', 'bold', 'FontSize', 12, 'FontName', 'arial')
xline(mean(energy_1st_cycle{2, 3}.*1E12), 'LineWidth', 1)
%}
end