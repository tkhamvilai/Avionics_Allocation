hardwares = cell(N_hardwares,1); % for symmetry

HW_CPIOM_H = 1;
HW_CPIOM_J = 2;
HW_CRDC_A = 3;
HW_CRDC_B = 4;
HW_LRU = 5;
HW_Switch = 6;

for i = 1:N_hardware_types
    for j = 1:N_hardwares_per_type(i)
        if i == HW_CPIOM_H % CPIOM-H HW type
            hardware_available_resources.memory = 200; % Each CRDC HW can hold up to this number of memories
            hardware_available_resources.IO = 0; % Each CRDC HW can hold up to this number of IOs
            hardware_available_resources.bandwidth = 200;
            hardware_required_resources.area = 0;
            hardware_redundancy_type = 0;
            hardware_type = i;
            
            hardwares{j} = ...
               Hardware(hardware_available_resources, hardware_required_resources, hardware_redundancy_type, hardware_type);
        
        elseif i == HW_CPIOM_J % CPIOM-J HW type
            hardware_available_resources.memory = 100; % Each CRDC HW can hold up to this number of memories
            hardware_available_resources.IO = 0; % Each CRDC HW can hold up to this number of IOs
            hardware_available_resources.bandwidth = 100;
            hardware_required_resources.area = 0;
            hardware_redundancy_type = 0;
            hardware_type = i;
            
            hardwares{sum(N_hardwares_per_type(1:i-1)) + j} = ...
               Hardware(hardware_available_resources, hardware_required_resources, hardware_redundancy_type, hardware_type);            
                
        elseif i == HW_CRDC_A % CRDC-A HW type
            hardware_available_resources.memory = 80; % Each CRDC HW can hold up to this number of memories
            hardware_available_resources.IO = 100; % Each CRDC HW can hold up to this number of IOs
            hardware_available_resources.bandwidth = 100;
            hardware_required_resources.area = 1;
            hardware_redundancy_type = 0;
            hardware_type = i;

            hardwares{sum(N_hardwares_per_type(1:i-1)) + j} = ...
               Hardware(hardware_available_resources, hardware_required_resources, hardware_redundancy_type, hardware_type);   
        
        elseif i == HW_CRDC_B % CRDC-B HW type
            hardware_available_resources.memory = 100; % Each CRDC HW can hold up to this number of memories
            hardware_available_resources.IO = 80; % Each CRDC HW can hold up to this number of IOs
            hardware_available_resources.bandwidth = 80;
            hardware_required_resources.area = 1;
            hardware_redundancy_type = 0;
            hardware_type = i;

            hardwares{sum(N_hardwares_per_type(1:i-1)) + j} = ...
               Hardware(hardware_available_resources, hardware_required_resources, hardware_redundancy_type, hardware_type);   
        
        elseif i == HW_LRU % LRU HW type
            hardware_available_resources.memory = 0; % Each LRU HW can hold up to this number of memories
            hardware_available_resources.IO = 0; % Each LRU HW can hold up to this number of IOs
            hardware_available_resources.bandwidth = 0;
            hardware_required_resources.area = 0;
            hardware_redundancy_type = 1;
            hardware_type = i;

            hardwares{sum(N_hardwares_per_type(1:i-1)) + j} = ...
               Hardware(hardware_available_resources, hardware_required_resources, hardware_redundancy_type, hardware_type);
        
        elseif i == HW_Switch % Switch HW type
            hardware_available_resources.memory = 1; % Each Switch HW can hold up to this number of memories
            hardware_available_resources.IO = 1; % Each Switch HW can hold up to this number of IOs
            hardware_available_resources.bandwidth = 1;
            hardware_required_resources.area = 0;
            hardware_redundancy_type = 1;
            hardware_type = i;

            hardwares{sum(N_hardwares_per_type(1:i-1)) + j} = ...
               Hardware(hardware_available_resources, hardware_required_resources, hardware_redundancy_type, hardware_type);        
        end
    end
end