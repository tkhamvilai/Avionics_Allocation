load weights.mat
% W = zeros(N_softwares, N_locations);
% for i = SW_Data_Acquisition_ind
%     w = get_task_weights(softwares{i,1}.required_IO, location_topology, ...
%         N_locations_per_type(location_CRDC), IO_location);
%     W(i,N_locations_per_type(location_CPIOM)+1:N_locations_per_type(location_CPIOM)+N_locations_per_type(location_CRDC)) = w';
% end