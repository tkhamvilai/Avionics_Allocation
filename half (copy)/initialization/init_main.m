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

N_hardware_types = 6; % comply with Hardware.m
N_hardwares_per_type = [12, ... % CPIOM-H
                        10, ... % CPIOM-J
                       7*2, ... % Switch
                       8*2, ... % CRDC-A
                       7*2, ... % CRDC-B
                      11*2]; % AFDX link
N_hardwares = sum(N_hardwares_per_type);

N_software_types = 6; % comply with Software.m
N_softwares_per_type = [16*2*2, ... % Avionics-H
                        11*2*2, ... % Avionics-J
                          12, ... % Allocator (3 on each CPIOM type for both sides)
                        sum(N_hardwares_per_type(1,1:2)), ... % Status check
                        100, ... % Data acquisiton
                         7*2]; % Switch
N_softwares = sum(N_softwares_per_type);

disp('Initializing locations...')
init_location;
disp('Initializing hardwares...')
init_HW;
disp('Initializing softwares...')
init_SW;

disp('Initializing indices...')
init_indices_symm
disp('Initializing resources...')
init_resources_symm
disp('Initializing weights...')
init_weights