function cfg = config()
    cfg.bmark = "DRD_GEMM";
    cfg.lut_dir = "./inputs";
    cfg.lut_filename = "instruction_cycles_aligned_commas_v2"
    %stat_code_floor
    cfg.input_dir = "./inputs";
    cfg.out_dir = "./outputs";
    cfg.lut_max_cycles = 48;
    cfg.tclk = 7.5e-9;
    cfg.twindow = 10e-12;
    cfg.vdd = 1.2;
    cfg.vref = 1.2
    cfg.i_unit = 12e-6;
    cfg.i_unit_reactive = 60e-6;
    cfg.i_unit_proactive = cfg.i_unit;
    cfg.i_max = 255*cfg.i_unit;
    cfg.tcomp_reactive = 1e-9;
    cfg.cap_out = 500e-12;
    cfg.limit = 100E3;
end