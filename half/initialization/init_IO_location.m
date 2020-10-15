%% Put IOs to Locations
N_IO_per_location = [200 125 125 125 125 6 26 22 16 8 14 12 ...
                         125 125 125 125   26 22 16 8 14 12]; % the number of IOs per location
assert(sum(N_IO_per_location) == N_IO);

% cvx_solver Gurobi_2
cvx_begin quiet
    variable X_IO_location(N_IO, N_IO_location) binary
    subject to
        sum(X_IO_location, 1) == N_IO_per_location; % each location host this number of IO
        sum(X_IO_location, 2) == 1; % each IO must be allocated        
cvx_end
cvx_clear
X_IO_location = full(X_IO_location);
IO_location = zeros(N_IO, 2); % [IO location, IO types]
for i = 1:N_IO
    IO_location(i,1) = find(X_IO_location(i,:) == 1) + N_locations_per_type(location_CRDC);
end
ind = 1;
for i = 1:N_IO_types
    IO_location(ind:ind+N_IO_per_IO_types(i),2) = i;
    ind = ind + N_IO_per_IO_types(i);
end
IO_location(end,:) = [];