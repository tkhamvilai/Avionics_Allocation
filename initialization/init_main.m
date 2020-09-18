% always assume symmetry
rng(0); % reset random seed

N_IO_location = 24;
N_install_locations = 12;
N_Avionics_Bay = 4;
N_location_types = 2; % N_IO_location and N_Avionics_Bay
N_locations_per_type = [N_install_locations, N_Avionics_Bay];
N_locations = sum(N_locations_per_type);

disp('Initializing IO...')
init_IO;
disp('Initializing topology...')
init_topology;
disp('Initializing IO location symm...')
init_IO_location_symm; % symmetry only, for now

N_hardware_types = 5; % comply with Hardsoft.m
N_hardwares_per_type = [10, 6, N_install_locations + N_Avionics_Bay, ceil(N_CRDC/2)*2, 0];
N_hardwares = sum(N_hardwares_per_type);

N_software_types = 6; % comply with Software.m
N_softwares_per_type = [6, 6, sum(N_hardwares_per_type(1,1:2)), 1196, N_install_locations + N_Avionics_Bay, 0];
N_softwares = sum(N_softwares_per_type);

disp('Initializing locations...')
init_location;
disp('Initializing hardwares...')
init_HW;
disp('Initializing softwares...')
init_SW;