function plot_activity(cfg, traces, code_traces, title_str)

act_vect = [];

for ii = 1:size(code_traces,2)
    hold on 
    %figure(1);
    %(traces.time_trace(1:traces.vect_len), voltages(1:traces.vect_len,ii), 'DisplayName', string(legend_str(ii)));
    %xlabel('Time [s]');
    %ylabel('Voltage [V]');
    %set(gca, 'FontWeight', 'bold', 'FontSize', 18, 'FontName', 'arial')
    act_vect = [act_vect get_activity(code_traces(1:traces.vect_len,ii), 'b', 8)];
end
   act_vect
end