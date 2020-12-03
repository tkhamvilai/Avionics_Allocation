softwares = cell(N_softwares, 1);

SW_Avionics_H = 1;
SW_Avionics_J = 2;
SW_Allocator_H = 3;
SW_Allocator_J = 4;
SW_Status_check_H = 5;
SW_Status_check_J = 6;
SW_Data_acquisition = 7;
SW_LRU = 8;
SW_Switch = 9;

% Allocate IO for Data acquisition SW
% cvx_solver Gurobi_2
cvx_begin quiet
variable X_IO_SW(N_IO, N_softwares_per_type(SW_Data_acquisition)) binary
subject to
    sum(X_IO_SW, 1) >= 1; % each sw must require at least one IO
    sum(X_IO_SW, 2) == 1; % each IO must be allocated
cvx_end
cvx_clear
X_IO_SW = full(X_IO_SW);
% end Allocate IO for Data acquisiton SW

for i = 1:N_software_types
    for j = 1:N_softwares_per_type(i)
        if i == SW_Avionics_H % Avionics-H SW type
           software_required_resources.memory = 10;
           software_required_resources.IO = [];
           software_required_resources.bandwidth = 10;
           software_redundancy_type = 1;
           software_type = i;

           softwares{j} = ...
               Software(software_required_resources, software_redundancy_type, software_type);
           
        elseif i == SW_Avionics_J % Avionics-J SW type
           software_required_resources.memory = 10;
           software_required_resources.IO = [];
           software_required_resources.bandwidth = 10;
           software_redundancy_type = 1;
           software_type = i;

           softwares{sum(N_softwares_per_type(1:i-1)) + j} = ...
               Software(software_required_resources, software_redundancy_type, software_type);
           
        elseif i == SW_Allocator_H % Allocator SW type
           software_required_resources.memory = 5;
           software_required_resources.IO = [];
           software_required_resources.bandwidth = 5;
           software_redundancy_type = 1;
           software_type = i;

           softwares{sum(N_softwares_per_type(1:i-1)) + j} = ...
               Software(software_required_resources, software_redundancy_type, software_type);
           
        elseif i == SW_Allocator_J % Allocator SW type
           software_required_resources.memory = 5;
           software_required_resources.IO = [];
           software_required_resources.bandwidth = 5;
           software_redundancy_type = 1;
           software_type = i;

           softwares{sum(N_softwares_per_type(1:i-1)) + j} = ...
               Software(software_required_resources, software_redundancy_type, software_type);
            
        elseif i == SW_Status_check_H % Status check SW type
           software_required_resources.memory = 2;
           software_required_resources.IO = [];
           software_required_resources.bandwidth = 2;
           software_redundancy_type = 1;
           software_type = i;

           softwares{sum(N_softwares_per_type(1:i-1)) + j} = ...
               Software(software_required_resources, software_redundancy_type, software_type);
           
        elseif i == SW_Status_check_J % Status check SW type
           software_required_resources.memory = 2;
           software_required_resources.IO = [];
           software_required_resources.bandwidth = 2;
           software_redundancy_type = 1;
           software_type = i;

           softwares{sum(N_softwares_per_type(1:i-1)) + j} = ...
               Software(software_required_resources, software_redundancy_type, software_type);
        
        elseif i == SW_Data_acquisition % Data acquisition SW type
           software_required_resources.memory = get_random_value_from_prob_vector([0.9,0.1],[1,2]);
           software_required_resources.IO = IO_location(find(X_IO_SW(:,j) == 1),2);
           software_required_resources.bandwidth = 0;
           software_redundancy_type = 0;
           software_type = i;

           softwares{sum(N_softwares_per_type(1:i-1)) + j} = ...
               Software(software_required_resources, software_redundancy_type, software_type);
           
        elseif i == SW_LRU % Data acquisition SW type
           software_required_resources.memory = 0;
           software_required_resources.IO = [];
           software_required_resources.bandwidth = 0;
           software_redundancy_type = 0;
           software_type = i;

           softwares{sum(N_softwares_per_type(1:i-1)) + j} = ...
               Software(software_required_resources, software_redundancy_type, software_type);
           
        elseif i == SW_Switch % Data acquisition SW type
           software_required_resources.memory = 0;
           software_required_resources.IO = [];
           software_required_resources.bandwidth = 0;
           software_redundancy_type = 0;
           software_type = i;

           softwares{sum(N_softwares_per_type(1:i-1)) + j} = ...
               Software(software_required_resources, software_redundancy_type, software_type);
        end
    end
end

