%% Activity factor from code vector

function accumulated_dist = get_activity(code_vector, mode, array_size)
    code_vect_len = length(code_vector);
    accumulated_dist = 0;
    if(mode == 'u')
        %Unary
        weights = ones(1, array_size);
    elseif(mode == 'b')
        %Binary
        for k = 1:array_size
            weights(k) = 2^(array_size-k);  
        end
    else
        error("Unrecognized mode");
    end
    weights
    hamming_dist = zeros(1, code_vect_len-1);
    for i = 1:code_vect_len-1
        loop_percentage(i, code_vect_len, 10)
        xor_dec = bitxor(code_vector(i), code_vector(i+1));
        xor_bits = dec2bin(xor_dec, array_size) == '1';
        hamming_dist(i) = sum(weights .* xor_bits);
        accumulated_dist = accumulated_dist + hamming_dist(i);
    end
end