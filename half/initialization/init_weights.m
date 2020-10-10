W = [];
for i = 1:N_softwares_symm
    w = get_task_weights(softwares{i,1}.required_IO, location_topology, N_locations_symm, IO_location_symm);
    W = [W; w'];
end