%initialize 
clear;
close all;

%configuration
global_cfg = config();

%load data
traces = load_traces(global_cfg, 1);
lut = load_lut(global_cfg);

%create clock trace
plot_clk = 0;
clk = create_clock_trace(global_cfg, traces, plot_clk);

%calculate code
code_round = "LUT"; %options: "LUT", "ROUND", "FLOOR", "CEIL"
instr_cycle_codes = calc_instr_cycle_codes(global_cfg, traces, clk, lut, code_round);
corr = lut_correct(global_cfg, lut, traces, clk, instr_cycle_codes);
code_round = "FLOOR"
instr_cycle_codes = calc_instr_cycle_codes(global_cfg, traces, clk, lut, code_round, corr);



%%
%simulations
proact_cfg = proact_config(global_cfg);
%drift_vect = ilsb_drift(global_cfg, traces, +500, 1);
%drift_vect = ilsb_sine(global_cfg, traces, 0.05, 5000);
drift_vect = ilsb_step(global_cfg, traces, 50e-6, 100e-6, +1000);
reactive_trace = sim_reactive(global_cfg, clk, traces, drift_vect, proact_cfg.drift_en);
tic
proactive_trace = sim_proactive_cycle(global_cfg, proact_cfg, clk, traces, lut, instr_cycle_codes, drift_vect);
toc
%sine_vect = ilsb_sine(global_cfg, traces, 0.05, 5000);
results.voltages = [reactive_trace.cap_voltage; proactive_trace.cap_voltage];
plot_voltages(global_cfg, traces, results.voltages', ["reactive", "proactive"], drift_vect, "n");

figure(2);
hold on
yyaxis right
plot(proactive_trace.integ_corrs);

yyaxis left
plot(proactive_trace.integ_trace);
yline(proact_cfg.integ_thresh_high, 'b')
yline(proact_cfg.integ_window, 'r')
yline(proact_cfg.integ_thresh_low, 'k--')
yline(-proact_cfg.integ_thresh_high, 'b')
yline(-proact_cfg.integ_thresh_low, 'k--')
yline(-proact_cfg.integ_window, 'r')
hold off

%%
tic
window_sizes = [20 30 50 70];
pwms = ["n" "h"];
fract_lsbs = [0.7 0.6 0.4]
pwm_vhist = [0.1 0.05 0.02]
proact_cfg.integ_window = 30;
proact_cfg.pwm_en = "n";
proact_cfg.corr_table_en = "n";
decay_factors = [0.2 0.3 0.4 0.5];
results.voltages = [];
proact_cfg.corr_frac_lsb = 0.25
labels = [];
for jj = 1:length(window_sizes)
for ii = 1:length(decay_factors)
    %pwms(ii)
    proact_cfg.integ_window = window_sizes(jj);
    proact_cfg.integ_thresh = 0.9 * proact_cfg.integ_window;
    %proact_cfg.pwm_en = pwms(ii);
    %fract_lsbs(ii)
    %proact_cfg.corr_frac_lsb = fract_lsbs(ii);
    proact_cfg.decay_factor = decay_factors(ii);
    labels = [labels; "W:"+window_sizes(jj)+"Fract:"+decay_factors(ii)];
    "W:"+window_sizes(jj)+"decay:"+decay_factors(ii)
    proactive_trace = sim_proactive_cycle(global_cfg, proact_cfg, clk, traces, lut, instr_cycle_codes, drift_vect);
    results.voltages = [results.voltages; proactive_trace.cap_voltage];
    
end
end
toc

plot_voltages(global_cfg, traces, results.voltages', labels, drift_vect, "n");
%%
code_traces = [reactive_trace.code_reactive; proactive_trace.code_corrected];
plot_activity(global_cfg, traces, code_traces');
plot_correction(global_cfg, traces, reactive_trace, proactive_trace);

%write outputs
write_outputs(global_cfg, traces, reactive_trace, proactive_trace);