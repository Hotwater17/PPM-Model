function ilsb_vect = ilsb_drift(cfg, traces, vin_slope, repeat_count, offset)

%% Vin slow rise influence on cfg.i_unit_proactive
% cfg.i_unit_proactive slope: 
%Vin slope: 100mV/s : 
%Unit current slope: 51uA/V = 5.1uA/s
%Code slope: 0.425/s OR 1LSB/2.35s

%vin_slope = +1000 %V/s  
curr_slope = 51E-6*vin_slope %A/V * vin_slope = A/s
code_slope = curr_slope/cfg.i_unit_proactive % LSB/s
delta_i_unit = cfg.i_unit_proactive + linspace(0, cfg.twindow*curr_slope*traces.vect_len*repeat_count, traces.vect_len*repeat_count);

i_lsb_start = cfg.i_unit_proactive
i_lsb_stop = cfg.i_unit_proactive + curr_slope*cfg.twindow*traces.vect_len*repeat_count
i_change = ((i_lsb_stop-i_lsb_start)/i_lsb_start)*100
i_full_start = i_lsb_start*255
i_full_stop = i_lsb_stop*255
code_change = cfg.twindow*code_slope*traces.vect_len*repeat_count
vin_change = cfg.twindow*vin_slope*traces.vect_len* repeat_count

figure(2);
%plot(traces.time_trace(1:traces.vect_len*repeat_count), delta_i_unit(1:traces.vect_len*repeat_count));

ilsb_vect.ilsb_vect = delta_i_unit;
end