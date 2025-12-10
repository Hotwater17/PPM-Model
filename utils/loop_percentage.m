%% Loop percentage display function
function loop_percentage(iteration, length, percentage)
    if(mod(iteration/length, percentage*0.01) == 0)
        disp((iteration/length)*100+"%");
    end
end