N_softwares_per_type_symm = N_softwares_per_type/2;
N_softwares_symm = N_softwares/2;
softwares = cell(N_softwares_symm, 1);

% Allocate IO for Data acquisiton SW
Data_acquisiton_SW_ind = 4;
% cvx_solver Gurobi_2
cvx_begin quiet
variable X_IO_SW(N_IO_symm, N_softwares_per_type_symm(Data_acquisiton_SW_ind)) binary
subject to
    sum(X_IO_SW, 2) == 1; % each IO must be allocated
    for i = 1:N_softwares_per_type_symm(Data_acquisiton_SW_ind)
        sum(X_IO_SW(:,i)) >= 1;
    end
cvx_end
cvx_clear
X_IO_SW = full(X_IO_SW);
% end Allocate IO for Data acquisiton SW

for i = 1:N_software_types
    for j = 1:N_softwares_per_type_symm(i)
        if i == 1 % Processing SW type
           software_required_resources.memory = 10;
           software_required_resources.IO = 0;
           software_required_resources.bandwidth = 10;
           software_redundancy_type = 1;
           software_type = i;

           softwares{j} = ...
               Software(software_required_resources, software_redundancy_type, software_type);
        elseif i == 2 % Allocator SW type
           software_required_resources.memory = 5;
           software_required_resources.IO = 0;
           software_required_resources.bandwidth = 5;
           software_redundancy_type = 1;
           software_type = i;

           softwares{sum(N_softwares_per_type_symm(1:i-1)) + j} = ...
               Software(software_required_resources, software_redundancy_type, software_type);
            
        elseif i == 3 % Status check SW type
           software_required_resources.memory = 2;
           software_required_resources.IO = 0;
           software_required_resources.bandwidth = 2;
           software_redundancy_type = 1;
           software_type = i;

           softwares{sum(N_softwares_per_type_symm(1:i-1)) + j} = ...
               Software(software_required_resources, software_redundancy_type, software_type);
        
        elseif i == 4 % Data acquisition SW type
           software_required_resources.memory = get_random_value_from_prob_vector([0.5,0.5],[1,2]);
           software_required_resources.IO = IO_location_symm(find(X_IO_SW(:,j) == 1),2);
           software_required_resources.bandwidth = [];
           software_redundancy_type = 0;
           software_type = i;

           softwares{sum(N_softwares_per_type_symm(1:i-1)) + j} = ...
               Software(software_required_resources, software_redundancy_type, software_type);
        elseif i == 5 % Switch SW type
           software_required_resources.memory = 1;
           software_required_resources.IO = 1;
           software_required_resources.bandwidth = 1;
           software_redundancy_type = 4;
           software_type = i;

           softwares{sum(N_softwares_per_type_symm(1:i-1)) + j} = ...
               Software(software_required_resources, software_redundancy_type, software_type);
        elseif i == 6 % Communication SW type
            % not used right now
        end
    end
end

