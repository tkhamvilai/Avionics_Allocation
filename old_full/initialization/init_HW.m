hardwares = cell(N_hardwares,1); % for symmetry

for i = 1:N_hardware_types
    for j = 1:N_hardwares_per_type(i)
        if i == 1 % CPIOM-H HW type
            hardware_available_resources.memory = 200; % Each CRDC HW can hold up to this number of memories
            hardware_available_resources.IO = 0; % Each CRDC HW can hold up to this number of IOs
            hardware_available_resources.bandwidth = 200;
            hardware_required_resources.area = 2;
            hardware_redundancy_type = 0;
            hardware_type = i;
            
            hardwares{j} = ...
               Hardware(hardware_available_resources, hardware_required_resources, hardware_redundancy_type, hardware_type);
        
        elseif i == 2 % CPIOM-J HW type
            hardware_available_resources.memory = 100; % Each CRDC HW can hold up to this number of memories
            hardware_available_resources.IO = 0; % Each CRDC HW can hold up to this number of IOs
            hardware_available_resources.bandwidth = 100;
            hardware_required_resources.area = 1;
            hardware_redundancy_type = 0;
            hardware_type = i;
            
            hardwares{sum(N_hardwares_per_type(1:i-1)) + j} = ...
               Hardware(hardware_available_resources, hardware_required_resources, hardware_redundancy_type, hardware_type);            
        
        elseif i == 3 % Switch HW type
            hardware_available_resources.memory = 1; % Each CRDC HW can hold up to this number of memories
            hardware_available_resources.IO = 1; % Each CRDC HW can hold up to this number of IOs
            hardware_available_resources.bandwidth = 1;
            hardware_required_resources.area = 1;
            hardware_redundancy_type = 1;
            hardware_type = i;

            hardwares{sum(N_hardwares_per_type(1:i-1)) + j} = ...
               Hardware(hardware_available_resources, hardware_required_resources, hardware_redundancy_type, hardware_type);
        
        elseif i == 4 % CRDC-A HW type
            hardware_available_resources.memory = 80; % Each CRDC HW can hold up to this number of memories
            hardware_available_resources.IO = 100; % Each CRDC HW can hold up to this number of IOs
            hardware_available_resources.bandwidth = 100;
            hardware_required_resources.area = 1;
            hardware_redundancy_type = 0;
            hardware_type = i;

            hardwares{sum(N_hardwares_per_type(1:i-1)) + j} = ...
               Hardware(hardware_available_resources, hardware_required_resources, hardware_redundancy_type, hardware_type);   
        
        elseif i == 5 % CRDC-B HW type
            hardware_available_resources.memory = 100; % Each CRDC HW can hold up to this number of memories
            hardware_available_resources.IO = 80; % Each CRDC HW can hold up to this number of IOs
            hardware_available_resources.bandwidth = 80;
            hardware_required_resources.area = 1;
            hardware_redundancy_type = 0;
            hardware_type = i;

            hardwares{sum(N_hardwares_per_type(1:i-1)) + j} = ...
               Hardware(hardware_available_resources, hardware_required_resources, hardware_redundancy_type, hardware_type);   
        
        elseif i == 6 % Communication SW type
            % not used right now
        end
    end
end