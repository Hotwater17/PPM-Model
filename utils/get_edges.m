%% Detect edge

function edge_indices = get_edges(signal, vth, edge_type)
    edge_indices = 0;
    for ii = 2:length(signal)
        if(edge_type == 'r')
            if((signal(ii-1) < vth ) && (signal(ii) > vth))
                edge_indices = [edge_indices ii];
            end
        elseif(edge_type == 'f')
            if((signal(ii-1) > vth ) && (signal(ii) < vth))
                edge_indices = [edge_indices ii];
            end
        else 
            error("Unknown edge type")
        end
    end
end