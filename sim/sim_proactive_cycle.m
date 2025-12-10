function proactive_cycle = sim_proactive_cycle(global_cfg, proact_cfg, clk, traces, lut, codes, drift)
disp("Simulating Proactive PPM with per-instruction cycle codes...");
%% Proactive mechanism - cycle based

%tic
%datetime
%{
figure(6);
hold on
yyaxis left
plot(traces.time_trace(1:traces.vect_len).*1E6, cap_cycle_voltage(1:traces.vect_len),'r', 'LineWidth', 1);
%}
cycle_corr_factor = zeros(lut.n_instr, lut.n_cycles_max);
cycle_corr_accum = zeros(lut.n_instr, lut.n_cycles_max);


ldo_cycle_current = zeros(1,length(traces.vect_len));
energy_diff = zeros(1,length(traces.vect_len));
cap_cycle_energy = zeros(1,length(traces.vect_len));
cap_cycle_voltage = zeros(1,length(traces.vect_len));
code_corrected = zeros(1, length(traces.vect_len));
cap_cycle_voltage(1) = global_cfg.vdd;
cap_cycle_energy(1) = (global_cfg.cap_out*cap_cycle_voltage(1)^2)/2;

pwm_max_ticks = proact_cfg.pwm_period/global_cfg.twindow;
pwm_tick_cnt = 0;
pwm_duty = 5;
pwm_tick_thresh = ((pwm_duty*0.01)*pwm_max_ticks);


pwm_state = 0;
pwm_v_diff = zeros(1, length(clk.clk_edges_obtained));
pwm_dc_trace = zeros(1, length(clk.clk_edges_obtained));
corr_trace = zeros(1, length(traces.vect_len));
current_diff = zeros(1, length(traces.vect_len));
corr_step = 1;
global_comp_accum = 0;
global_integ_corr = 0;
total_comp_ticks = 0;
integ_ii = 1;
integ_val = 0;
next_cycle_corr = 0;
current_corr = 0;
%current_pull 
integ_error = 0;
ll = 750;
kk = 1;
sample_voltage = zeros(1, traces.vect_len/proact_cfg.corr_delay);
sample_time = zeros(1,traces.vect_len/proact_cfg.corr_delay);
current_code = 0;
current_ilsb = global_cfg.i_unit_proactive;
pwm_trace = zeros(1, length(traces.vect_len));
integ_trace = [];
integ_corrs = [];

for ii = 2:traces.vect_len
    loop_percentage(ii, traces.vect_len, 5);
    
    % every timestep of trace:
    % draw current from cap with current trace
    % push current to cap with LDO code
    if(proact_cfg.pwm_en ~= 'n')
        pwm_tick_cnt = pwm_tick_cnt+1;
        if(pwm_tick_cnt >= pwm_tick_thresh)
            pwm_state = 0;
        else 
            pwm_state = 1;
        end
        pwm_trace(ii) = pwm_state;
        if(pwm_tick_cnt >= pwm_max_ticks)
            pwm_tick_cnt = 0;
            pwm_state = 0;
        end
        %ldo_cycle_current(ii) = codes.code_cycle(ii)*global_cfg.i_unit_proactive + pwm_state*proact_cfg.i_pwm;
    end
    if(proact_cfg.corr_en == 't')
        if(ll == proact_cfg.corr_delay)
            ll = 0;
            if(cap_cycle_voltage(ii-1) < global_cfg.vref)
                current_corr = corr_step;
                next_cycle_corr = corr_step;
            elseif(cap_cycle_voltage(ii-1) > global_cfg.vref)
                current_corr = -corr_step;
                next_cycle_corr= -corr_step;  
            end
            cycle_corr_accum(codes.instr_code_trace(ii-1), codes.cycle_trace(ii-1)) = cycle_corr_accum(codes.instr_code_trace(ii-1), codes.cycle_trace(ii-1)) + next_cycle_corr;
            if(abs(cycle_corr_accum(codes.instr_code_trace(ii-1), codes.cycle_trace(ii-1))) == proact_cfg.cycle_corr_thresh)
                cycle_corr_accum(codes.instr_code_trace(ii-1), codes.cycle_trace(ii-1)) = 0;
                cycle_corr_factor(codes.instr_code_trace(ii-1), codes.cycle_trace(ii-1)) = cycle_corr_factor(codes.instr_code_trace(ii-1), codes.cycle_trace(ii-1)) + next_cycle_corr;
            end
            global_comp_accum = global_comp_accum + next_cycle_corr;
            %Save voltage sampled by comparator and the sample time
            sample_time(kk) = traces.time_trace(ii-1);
            sample_voltage(kk) = cap_cycle_voltage(ii-1);
            kk = kk + 1;
            %else
            %    current_corr = 0;
            %    next_cycle_corr = 0;
            total_comp_ticks = total_comp_ticks + 1;
            integ_ii = integ_ii + 1;
            
            if(integ_ii == proact_cfg.integ_window) 
                integ_ii = 0;
                
                if(global_comp_accum > +proact_cfg.integ_thresh_low) 
                    if(global_comp_accum > +proact_cfg.integ_thresh_high)
                        if(global_comp_accum > +proact_cfg.integ_thresh_super)
                            global_integ_corr = global_integ_corr - proact_cfg.integ_super_step;
                        else
                            global_integ_corr = global_integ_corr - proact_cfg.integ_high_step;
                        end
                    else
                        global_integ_corr = global_integ_corr - proact_cfg.integ_low_step;
                    end
                elseif(global_comp_accum < -proact_cfg.integ_thresh_low)
                    if(global_comp_accum < -proact_cfg.integ_thresh_high)
                        if(global_comp_accum < -proact_cfg.integ_thresh_super)
                            global_integ_corr = global_integ_corr + proact_cfg.integ_super_step;
                        else
                            global_integ_corr = global_integ_corr + proact_cfg.integ_high_step;
                        end
                    else
                        global_integ_corr = global_integ_corr + proact_cfg.integ_low_step;
                    end
                end
                integ_corrs = [integ_corrs global_integ_corr];
                integ_trace = [integ_trace global_comp_accum];
                global_comp_accum = 0;%floor(global_comp_accum*proact_cfg.decay_factor);
            end
        end
        
        ll = ll + 1;
        corr_trace(ii) = current_corr;

         
        if(proact_cfg.drift_en == 't')
            current_ilsb = drift.ilsb_vect(ii);
        else
            current_ilsb = global_cfg.i_unit_proactive;
        end

        if(proact_cfg.corr_table_en == 't')
            current_code = codes.code_cycle(ii) + next_cycle_corr- global_integ_corr*proact_cfg.corr_frac_lsb +cycle_corr_factor(codes.instr_code_trace(ii-1), codes.cycle_trace(ii-1))*proact_cfg.corr_frac_lsb;%;
        else
            current_code = codes.code_cycle(ii) + next_cycle_corr - global_integ_corr*proact_cfg.corr_frac_lsb;
        end
        ldo_cycle_current(ii) = (current_code + pwm_state)*current_ilsb;  

        %ldo_cycle_current(ii) = codes.code_cycle(ii)*global_cfg.i_unit_proactive +i_corr*current_corr; %- i_corr*cycle_corr_factor(codes.instr_code_trace(ii), cycle_proactive(ii));
        %ldo_cycle_current(ii) = codes.code_cycle(ii)*global_cfg.i_unit_proactive - i_corr*cycle_corr_factor(codes.instr_code_trace(ii), cycle_proactive(ii));
        
        %ldo_cycle_current(ii) = (codes.code_cycle(ii)+next_cycle_corr)*global_cfg.i_unit_proactive;
        %ldo_cycle_current(ii) = (codes.code_cycle(ii)+next_cycle_corr-global_integ_corr)*delta_i_unit(ii);
        %ldo_cycle_current(ii) = (codes.code_cycle(ii)+next_cycle_corr-global_integ_corr+cycle_corr_factor(codes.instr_code_trace(ii-1), codes.cycle_trace(ii-1)))*delta_i_unit(ii);
        %code_corrected(ii) = codes.code_cycle(ii) + cycle_corr_factor(codes.instr_code_trace(ii), cycle_proactive(ii));
        code_corrected(ii) = current_code;
    else
        if(proact_cfg.drift_en == 't')
            current_ilsb = drift.ilsb_vect(ii);
        else
            current_ilsb = global_cfg.i_unit_proactive;
        end
        ldo_cycle_current(ii) = codes.code_cycle(ii)*current_ilsb;
    end
    % Calculate energy difference from LDO
    P_cap = cap_cycle_voltage(ii-1) * (traces.current_trace(ii) - ldo_cycle_current(ii));
    cap_cycle_energy(ii) = cap_cycle_energy(ii-1) - P_cap*global_cfg.twindow;
    cap_cycle_voltage(ii) = sqrt((2*cap_cycle_energy(ii))/global_cfg.cap_out);
    current_diff(ii) = traces.current_trace(ii) - ldo_cycle_current(ii);
    %At clock edge indices of ii, update pwm duty cycle
    if(find(clk.clk_edges_obtained == ii) ~= 0)
        pwm_v_diff(ll) = (cap_cycle_voltage(ii) - global_cfg.vref);
        pwm_dc_trace(ll) = pwm_duty;
        vcap_mean_diff = mean(cap_cycle_voltage(ii-proact_cfg.pwm_avg_window:ii)) - global_cfg.vref;
        if(proact_cfg.pwm_en == 'p')

            integ_error = (integ_error + (vcap_mean_diff * proact_cfg.pwm_Kp));
            pwm_duty = integ_error;
            pwm_duty = min(max(pwm_duty,0),100);
            pwm_tick_thresh = ((pwm_duty*0.01)*pwm_max_ticks);
            ll = ll + 1;
        elseif (proact_cfg.pwm_en == 'h')
            if(cap_cycle_voltage(ii) > (global_cfg.vref+proact_cfg.vhist))
                pwm_duty = pwm_duty - 1;
                pwm_duty = min(max(pwm_duty,0),100);
                pwm_tick_thresh = ((pwm_duty*0.01)*pwm_max_ticks);
            elseif(cap_cycle_voltage(ii) < (global_cfg.vref-proact_cfg.vhist))
                pwm_duty = pwm_duty + 1;
                pwm_duty = min(max(pwm_duty,0),100);
                pwm_tick_thresh = ((pwm_duty*0.01)*pwm_max_ticks);
            end
        end
    end
end

%{
figure(3);
subplot(2,1,1);
hold on
yyaxis left
plot(traces.time_trace(1:traces.vect_len), traces.current_trace(1:traces.vect_len));
yyaxis right
scatter(traces.time_trace(1:traces.vect_len), codes.code_cycle(1:traces.vect_len));
hold off

%subplot(3,1,2);
%hold on
%yyaxis left
%plot(traces.time_trace(1:traces.vect_len), cap_cycle_energy(1:traces.vect_len));
%yyaxis right
%scatter(traces.time_trace(1:traces.vect_len), codes.code_cycle(1:traces.vect_len));
%hold off

subplot(2,1,2);
%subplot(3,1,3);
hold on
yyaxis left
plot(traces.time_trace(1:traces.vect_len), cap_cycle_voltage(1:traces.vect_len));
yyaxis right
scatter(traces.time_trace(1:traces.vect_len), codes.code_cycle(1:traces.vect_len));
hold off

figure(4);
hold on


figure(5);
hold on
yyaxis left
plot(pwm_dc_trace)
yyaxis right
plot(pwm_v_diff);
yline(proact_cfg.vhist);
yline(-proact_cfg.vhist);
hold off

figure(6);
hold on
yyaxis left
plot(traces.time_trace(1:traces.vect_len).*1E6, cap_cycle_voltage,'b', 'LineWidth', 1);
yline(global_cfg.vref)
%yyaxis right
%plot(traces.time_trace(1:traces.vect_len).*1E6, corr_trace*0.25)

%plot(traces.time_trace(1:traces.vect_len).*1E6, traces.current_trace(1:traces.vect_len), 'r');
%xlim([18.5 18.9])
hold off
xlabel('time [us]')
ylabel('Output voltage [V]')
set(gca, 'FontWeight', 'bold', 'FontSize', 12, 'FontName', 'arial')
disp("Global accumulated comparator ticks:")
global_comp_accum
disp("Global comparator ticks:")
total_comp_ticks 
disp("Ratio:")
global_comp_accum/total_comp_ticks
%}
%toc
%datetime

proactive_cycle.cap_voltage = cap_cycle_voltage;
proactive_cycle.cap_energy = cap_cycle_energy;
proactive_cycle.ldo_current = ldo_cycle_current;
proactive_cycle.code_corrected = code_corrected;
proactive_cycle.corr_trace = corr_trace;
proactive_cycle.pwm_trace = pwm_trace;
proactive_cycle.sample_voltage = sample_voltage;
proactive_cycle.sample_time = sample_time;
proactive_cycle.cycle_corr_factor = cycle_corr_factor;
proactive_cycle.global_integ_corr = global_integ_corr;
proactive_cycle.integ_corrs = integ_corrs;
proactive_cycle.integ_trace = integ_trace;

end