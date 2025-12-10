function ilsb_vect = ilsb_sine(cfg, traces, amplitude, frequency)
  
  %% Generate ILSB variation as a sine wave
  % cfg: global configuration structure
  % cfg.i_unit_proactive: nominal unit current per cycle
  % amplitude: amplitude of vin variation (in volts)
  % frequency: frequency of sine wave variation (in Hz)
  curr_slope = 51E-6*amplitude %A/V * amplitude = A/s
  t = linspace(0, traces.end_time, traces.vect_len); % time vector

     delta_i_unit = cfg.i_unit_proactive + curr_slope * sin(2 * pi * frequency * t);

    figure(2);
    plot(traces.time_trace(1:traces.vect_len), delta_i_unit(1:traces.vect_len));

    ilsb_vect.ilsb_vect = delta_i_unit;

end