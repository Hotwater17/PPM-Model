function ilsb_vect = ilsb_step(cfg, traces, tstart, tstop, vin_slope)

curr_slope = 51E-6*vin_slope %A/V * vin_slope = A/s
code_slope = curr_slope/cfg.i_unit_proactive % LSB/s

%Create slope between tstart and tstop
delta_i_unit = [cfg.i_unit_proactive*ones(1, round(tstart/cfg.twindow)), ...
    linspace(cfg.i_unit_proactive, cfg.i_unit_proactive + curr_slope*(tstop - tstart), round((tstop - tstart)/cfg.twindow)), ...
    (cfg.i_unit_proactive + curr_slope*(tstop - tstart))*ones(1, traces.vect_len - round(tstop/cfg.twindow))];



ilsb_vect.ilsb_vect = delta_i_unit;
end

