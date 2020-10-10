% always assume symmetry
rng(0); % reset random seed

disp('Initializing IO...')
N_IO_location = 22;
init_IO;

disp('Initializing locations...')
N_location_types = 4; % comply with Location.m
N_locations_per_type = [1; % CPIOM install location
                        9; % CRDC install location
                        1; % LRU install location
                        5]; % Switch install location
N_locations = sum(N_locations_per_type);
init_location;

disp('Initializing topology...')
init_topology;
disp('Initializing IO location...')
init_IO_location;

disp('Initializing hardwares...')
N_hardware_types = 6; % comply with Hardware.m
N_hardwares_per_type = [12, ... % CPIOM-H
                        10, ... % CPIOM-J                         
                        15, ... % CRDC-A
                        14, ... % CRDC-B
                        55, ... % LRU
                        5]; % Switch
N_hardwares = sum(N_hardwares_per_type);
init_HW;

disp('Initializing softwares...')
N_software_types = 7; % comply with Software.m
N_softwares_per_type = [16*2, ... % Avionics-H *2 for sw redandancy
                        11*2, ... % Avionics-J *2 for sw redandancy
                        3*2, ... % Allocator (3 for each CPIOM type)
                        sum(N_hardwares_per_type(1,[HW_CPIOM_H HW_CPIOM_J])), ... % Status check on CPIOM
                        1196, ...  % Data acquisiton
                        N_hardwares_per_type(HW_LRU), ... % LRU sw
                        N_hardwares_per_type(HW_Switch)]; % Switch sw
N_softwares = sum(N_softwares_per_type);
init_SW;

disp('Initializing indices...')
init_indices
disp('Initializing resources...')
init_resources
disp('Initializing weights...')
init_weights