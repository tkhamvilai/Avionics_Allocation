N_SW_resources = 3; % memory, IO, bandwidth
SW_required_resources = zeros(N_SW_resources, N_softwares_symm);
HW_available_resources = zeros(N_SW_resources, N_hardwares_symm);

N_HW_resources = 1; % area
HW_required_resources = zeros(N_HW_resources, N_hardwares_symm);
Location_available_resources = zeros(N_HW_resources, N_locations_symm);

for i = 1:N_softwares_symm
    SW_required_resources(1,i) = softwares{i,1}.required_memory;
    SW_required_resources(2,i) = length(softwares{i,1}.required_IO);
    SW_required_resources(3,i) = softwares{i,1}.required_bandwidth;
end

for i = 1:N_hardwares_symm
    HW_available_resources(1,i) = hardwares{i,1}.available_memory;
    HW_available_resources(2,i) = hardwares{i,1}.available_IO;
    HW_available_resources(3,i) = hardwares{i,1}.available_bandwidth;
    
    HW_required_resources(1,i) = hardwares{i,1}.required_area;
end

for i = 1:N_locations_symm
    Location_available_resources(1,i) = locations{i,1}.available_area;
end