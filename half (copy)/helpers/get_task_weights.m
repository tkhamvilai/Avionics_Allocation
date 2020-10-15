function w = get_task_weights(SW_required_IO,G,N_install_locations,IO_location)
%GET_TASK_WEIGHTS Summary of this function goes here
%   w is a vector of size N_location
%   where each element represents the weight of x for each location
%   Assumes SW, and N_install_locations are taken the symmetry into an account already.
    w = zeros(N_install_locations,1);
    if length(unique(SW_required_IO)) == 1
        unique_sw_io = SW_required_IO(1);
        cnt_unique_sw_io = length(SW_required_IO);
    else
        [cnt_unique_sw_io, unique_sw_io] = hist(SW_required_IO,unique(SW_required_IO));
    end
    for i = 1:length(unique_sw_io) % for each unique required IO type
        ind = find(IO_location(:,2) == unique_sw_io(i)); % find a IO location of this type
        for j = 1:length(ind) % for each available IO of this type
            for k = 1:N_install_locations % for each HW install location that SW will be allocated on
               w(k) = w(k) + distances(G, IO_location(ind(j),1), k); % add the distance from each IO location to each install location
            end
        end
        w = w * cnt_unique_sw_io(i); % multiply the multiplicity
    end
end

