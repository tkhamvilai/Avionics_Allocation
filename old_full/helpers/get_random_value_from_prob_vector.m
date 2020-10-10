function val = get_random_value_from_prob_vector(p,v)
%GET_RANDOM_VALUE_FROM_PROB_VECTOR Summary of this function goes here
%   Detailed explanation goes here
    P = cumsum(p);
    rnd = rand(1);
    for i = 1:length(P)
       if rnd <= P(i) 
           val = v(i);
           return
       end
    end
end

