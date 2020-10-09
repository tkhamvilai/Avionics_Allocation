%% Put IOs to Locations
% apply symmetry
N_IO_per_IO_types_symm = floor(N_IO_per_IO_types/2);
N_IO_symm = sum(N_IO_per_IO_types_symm);
N_IO_location_symmm = N_IO_location/2 + 1; % +1 for head and tail
N_IO_per_location_symm = [99 100 100 100 100 100 2 24 20 13 6 12 10]; % the number of IOs per location
% cvx_solver Gurobi_2
cvx_begin quiet
    variable X_IO_location_symm(N_IO_symm, N_IO_location_symmm) binary
    subject to
        sum(X_IO_location_symm, 2) == 1; % each IO must be allocated
        for i = 1:N_IO_location_symmm
            sum(X_IO_location_symm(:,i)) == N_IO_per_location_symm(i);
        end
cvx_end
cvx_clear
X_IO_location_symm = full(X_IO_location_symm);
IO_location_symm = zeros(N_IO_symm, 2); % [IO location, IO types]
for i = 1:N_IO_symm
    IO_location_symm(i,1) = find(X_IO_location_symm(i,:) == 1) + N_install_locations;
end
ind = 1;
for i = 1:N_IO_types
    IO_location_symm(ind:ind+N_IO_per_IO_types_symm(i),2) = i;
    ind = ind + N_IO_per_IO_types_symm(i);
end
IO_location_symm(end,:) = [];