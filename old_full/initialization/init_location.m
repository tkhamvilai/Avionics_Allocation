locations = cell(N_locations,1); % for symmetry

for i = 1:N_location_types
    for j = 1:N_locations_per_type(i)
        if i == 1 % CRDC installation location type
            location_available_resources.area = 5;
            locations_type = i;
            
            locations{j} = ...
               Location(location_available_resources, locations_type);
        elseif i == 2 % CPIOM installation location type
            location_available_resources.area = 20;
            locations_type = i;
            
            locations{sum(N_locations_per_type(1:i-1)) + j} = ...
               Location(location_available_resources, locations_type);           
        end
    end
end

