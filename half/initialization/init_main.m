% always assume symmetry
rng(0); % reset random seed

N_IO_location = 24;
N_install_locations = 12;
N_Avionics_Compartment = 2; % main avionics compartment
N_location_types = 2; % N_IO_location and N_Avionics_Compartment
N_locations_per_type = [N_install_locations, N_Avionics_Compartment];
N_locations = sum(N_locations_per_type);

disp('Initializing IO...')
init_IO;
disp('Initializing topology...')
init_topology;
disp('Initializing IO location symm...')
init_IO_location_symm; % symmetry only, for now

N_hardware_types = 6; % comply with Hardsoft.m
N_hardwares_per_type = [12, ... % CPIOM-H
                        10, ... % CPIOM-J
                         0, ... % Switch
                       8*2, ... % CRDC-A
                       8*2, ... % CRDC-B
                         0]; % AFDX link
N_hardwares = sum(N_hardwares_per_type);

N_software_types = 7; % comply with Software.m
N_softwares_per_type = [16*2, ... % Avionics-H
                        11*2, ... % Avionics-J
                          12, ... % Allocator (3 on each CPIOM type for both sides)
                        sum(N_hardwares_per_type(1,1:2)), ... % Status check
                        1196, ... % Data acquisiton
                           0, ... % Switch
                           0]; % Communication
N_softwares = sum(N_softwares_per_type);

disp('Initializing locations...')
init_location;
disp('Initializing hardwares...')
init_HW;
disp('Initializing softwares...')
init_SW;

Avionics_H_app_ind = [];
Avionics_J_app_ind = [];
Allocator_app_ind = [];
Status_Check_app_ind = [];
Data_Acquisiton_app_ind = [];
for i = 1:N_softwares_symm                
    if softwares{i,1}.software_type == 1 % Avionics-H
        Avionics_H_app_ind = [Avionics_H_app_ind i];
    elseif softwares{i,1}.software_type == 2 % Avionics-J
        Avionics_J_app_ind = [Avionics_J_app_ind i];
    elseif softwares{i,1}.software_type == 3 % Allocator
        Allocator_app_ind = [Allocator_app_ind i];
    elseif softwares{i,1}.software_type == 4 % Status check
        Status_Check_app_ind = [Status_Check_app_ind i];
    elseif softwares{i,1}.software_type == 5 % Data acquisiton
        Data_Acquisiton_app_ind = [Data_Acquisiton_app_ind i];
    elseif softwares{i,1}.software_type == 6 % Switch link

    elseif softwares{i,1}.software_type == 7 % Communication link

    end
end

CPIOM_H_ind = [];
CPIOM_J_ind = [];
CRDC_A_ind = [];
CRDC_B_ind = [];
for i = 1:N_hardwares_symm
    if hardwares{i,1}.hardware_type == 1 % CPIOM-H
        CPIOM_H_ind = [CPIOM_H_ind i];
    elseif hardwares{i,1}.hardware_type == 2 % CPIOM-J
        CPIOM_J_ind = [CPIOM_J_ind i];
    elseif hardwares{i,1}.hardware_type == 3 % Switch
        
    elseif hardwares{i,1}.hardware_type == 4 % CRDC-A
        CRDC_A_ind = [CRDC_A_ind i];
    elseif hardwares{i,1}.hardware_type == 5 % CRDC-B
        CRDC_B_ind = [CRDC_B_ind i];
    elseif hardwares{i,1}.hardware_type == 6 % AFDX link

    end
end