function cfg = proact_config(global_cfg)

cfg.corr_en = "t"
cfg.drift_en = "t"
cfg.pwm_en = "n"
cfg.corr_table_en = "n"
cfg.i_pwm = global_cfg.i_unit_proactive;
cfg.pwm_period = 1000E-12;
cfg.pwm_Kp = +1.0;
cfg.pwm_avg_window = 100;
cfg.corr_frac_lsb = 0.25;
cfg.drift_slope = 0.;
cfg.integ_window = 30;
cfg.cycle_corr_thresh = 8;
cfg.integ_low_coeff = 0.3;
cfg.integ_high_coeff = 0.6;
cfg.integ_super_coeff = 0.8;
cfg.integ_low_step = 1;
cfg.integ_high_step = 2;
cfg.integ_super_step = 3;
cfg.integ_thresh_low = cfg.integ_low_coeff * cfg.integ_window;
cfg.integ_thresh_high = cfg.integ_high_coeff * cfg.integ_window;
cfg.integ_thresh_super = cfg.integ_super_coeff * cfg.integ_window;
cfg.decay_factor = 0.4;
cfg.window = 100;
cfg.corr_delay = 1500;
cfg.vhist = 0.02;
cfg.vrefplus = 1.23;
cfg.i_corr = global_cfg.i_unit_proactive;

end