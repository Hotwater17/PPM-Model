function reactive = sim_reactive(cfg, clk, traces, drift, drift_en)
disp("Simulating reactive control...");
%tic
%datetime
cap_reactive_voltage = zeros(1, traces.vect_len);
cap_reactive_voltage(1) = cfg.vdd;
cap_reactive_energy(1) = (cfg.cap_out*cap_reactive_voltage(1)^2)/2;
datetime
current_code = 10;
code_reactive = zeros(1, traces.vect_len);
code_reactive(1) = current_code; 
t_steps = floor(cfg.tcomp_reactive/cfg.twindow);
step_cnt = 0;
% Change timestep to be 1ns (comparator clock)



for ii = 2:traces.vect_len
    loop_percentage(ii, traces.vect_len, 5);
    % if capacitor voltage is lower/higher than vref +- histheresis
    % increase/decrease code next cycle.
    % But need to simulate the binary load!!! otherwise its unary-like
    step_cnt = step_cnt + 1;
    if(step_cnt >= t_steps)
        step_cnt = 0;
        if(cap_reactive_voltage(ii-1) < cfg.vref)
            if(current_code < 255)
                current_code = code_reactive(ii-1) + 1;
            end
        else
            % Cap code to 0 and 255
            if(code_reactive(ii-1) > 0)
                current_code = code_reactive(ii-1) - 1;
            end
        end
    end
    code_reactive(ii) = current_code;
    if(drift_en == 't')
        ldo_reactive_current(ii) = code_reactive(ii)*drift.ilsb_vect(ii);
    else 
        ldo_reactive_current(ii) = code_reactive(ii)*cfg.i_unit_reactive;
    end
    P_reactive_cap = cap_reactive_voltage(ii-1) * (traces.current_trace(ii) - ldo_reactive_current(ii));
    cap_reactive_energy(ii) = cap_reactive_energy(ii-1) - P_reactive_cap * cfg.twindow;
    cap_reactive_voltage(ii) = sqrt((2*cap_reactive_energy(ii))/cfg.cap_out);
end

%{
figure(2);
subplot(3,1,1);
hold on
yyaxis left
plot(time_trace(1:vect_len), current_trace(1:vect_len));
plot(time_trace(1:vect_len), ldo_reactive_current(1:vect_len), 'r');
yyaxis right
scatter(time_trace(1:vect_len), code_reactive(1:vect_len));
hold off
subplot(3,1,2);
plot(time_trace(1:vect_len), cap_reactive_energy(1:vect_len));

hold on
subplot(3,1,3);
yyaxis left
plot(time_trace(1:vect_len), cap_reactive_voltage(1:vect_len));
yline(cfg.vref);
yyaxis right
scatter(time_trace(1:vect_len), code_reactive(1:vect_len));
hold off
%}


reactive.cap_voltage = cap_reactive_voltage;
reactive.cap_energy = cap_reactive_energy;
reactive.ldo_current = ldo_reactive_current;
reactive.code_reactive = code_reactive;

end