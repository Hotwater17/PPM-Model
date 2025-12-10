function plot_voltages(cfg, traces, voltages, legend_str, drift, drift_en)

pp_vect = [];
sd_vect = [];
for ii = 1:size(voltages,2)
    hold on 
    figure(1);
    if(drift_en == 't') yyaxis left ; end
    plot(traces.time_trace(1:traces.vect_len), voltages(1:traces.vect_len,ii), 'DisplayName', string(legend_str(ii)));
    xlabel('Time [s]');
    ylabel('Voltage [V]');
    set(gca, 'FontWeight', 'bold', 'FontSize', 18, 'FontName', 'arial')

    trace_sd = std(voltages(1:traces.vect_len,ii));
    trace_pp = max(voltages(1:traces.vect_len,ii)) - min(voltages(1:traces.vect_len,ii));

    pp_vect = [pp_vect trace_pp];
    sd_vect = [sd_vect trace_sd];
end
    if(drift_en == 't')
        yyaxis right
        plot(traces.time_trace(1:traces.vect_len), drift.ilsb_vect(1:traces.vect_len), 'DisplayName', 'ILSB Drift');
    end
    hold off;
    legend show;
    
    pp_vect
    sd_vect
end