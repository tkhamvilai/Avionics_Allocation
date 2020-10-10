%% Put IOs to Locations
N_IO_per_location = [200 100 100 100 100 100 6 26 22 16 8 14 12 ...
                         100 100 100 100 100   26 22 16 8 14 12]; % the number of IOs per location
% cvx_solver Gurobi_2
cvx_begin quiet
    variable X_IO_location(N_IO, N_IO_location) binary
    subject to
        sum(X_IO_location, 2) == 1; % each IO must be allocated
        % the number of IOs allocated to a location must be equal to N_IO_per_location
        for i = 1:N_IO_location
            sum(X_IO_location(:,i)) == N_IO_per_location(i);
        end
cvx_end
cvx_clear
X_IO_location = full(X_IO_location);
IO_location = zeros(N_IO, 2); % IO_ind -> [IO location, IO types]
for i = 1:N_IO
    IO_location(i,1) = find(X_IO_location(i,:) == 1) + N_install_locations;
end
ind = 1;
for i = 1:N_IO_types
    IO_location(ind:ind+N_IO_per_IO_types(i), 2) = i;
    ind = ind + N_IO_per_IO_types(i);
end
IO_location(end,:) = [];