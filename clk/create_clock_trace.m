
function    clk = create_clock_trace(cfg, traces, plot)
%% Create clock waveform

%Create it until the end_time, not just integer divider of clocks.
n_ticks = round(traces.end_time/cfg.tclk)
time_clk = linspace(0, n_ticks*cfg.tclk, n_ticks+1);
clk_voltages = zeros(n_ticks+1, 1);
clk_voltages(1) = 0;
for ii = 2:length(time_clk)
    clk_voltages(ii) = mod(ii+1, 2) * cfg.vdd;
end
%{
clk_ticks = cfg.tclk/cfg.twindow;

clk_trace = zeros(clk_ticks*length(clk_voltages), 1);
clk_edges_obtained = 0;
for ii = 1:length(time_clk)-1
%for ii = 1:10
    t_start = time_clk(ii);
    t_stop = time_clk(ii+1);
    for jj = 1:clk_ticks;
        kk = (ii)*clk_ticks + jj;
        clk_trace(kk) = clk_voltages(ii);
    end
end

for ii = 2:length(clk_trace)
    if(clk_trace(ii) ~= clk_trace(ii-1))
        clk_edges_obtained = [clk_edges_obtained ii-1];
    end
end

if(plot == 1)
figure(1)
hold on
yyaxis left
plot(clk_trace)
yyaxis right
plot(traces.current_trace)
hold off
end
%}
%% Clock creation - modified
clk_ticks = (cfg.tclk/cfg.twindow);
clk_indices = zeros(length(clk_voltages), 2);
clk_len = zeros(1,length(clk_voltages)-1);
for ii = 1:length(clk_voltages)
    if(clk_voltages(ii) == cfg.vdd)
        clk_trace(((ii-1)*clk_ticks):((ii*clk_ticks))) = clk_voltages(ii);
        clk_indices(ii,1) = ((ii-1)*clk_ticks);
        clk_indices(ii,2) = ((ii*clk_ticks));
        clk_indices(ii,3) = clk_voltages(ii);
    else 
        clk_trace(((ii-1)*clk_ticks)+1:((ii*clk_ticks)-1)) = clk_voltages(ii);
        clk_indices(ii,1) = ((ii-1)*clk_ticks)+1;
        clk_indices(ii,2) = ((ii*clk_ticks)-1);
        clk_indices(ii,3) = clk_voltages(ii);
    end
    
    %clk_len(ii) = clk_indices(ii,2) - clk_indices(ii,1);

end
for ii = 1:length(clk_voltages)-2
    clk_len(ii) = clk_indices(ii+2,1) - clk_indices(ii,1);
    if(clk_len(ii) ~=1500)
        ii
    end
end
ldiff = length(clk_trace) - length(traces.current_trace)
clk_trace(length(clk_trace)-ldiff+1:length(clk_trace)) = [];    

clk_edges_obtained = 0;
for ii = 2:length(clk_trace)
    if(clk_trace(ii) ~= clk_trace(ii-1))
        clk_edges_obtained = [clk_edges_obtained ii-1];
    end
end


if(plot == 1)

figure(2);
hold on
yyaxis left

plot(clk.clk_trace(end-150000:end))

yyaxis right

plot(traces.current_trace(end-150000:end))
hold off

end


clk.clk_trace = clk_trace;
clk.clk_indices = clk_indices;
clk.clk_edges_obtained = clk_edges_obtained;

end