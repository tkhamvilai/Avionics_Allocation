locations = cell(N_locations,1); % for symmetry

location_CPIOM = 1;
location_CRDC = 2;
location_LRU = 3;
location_Switch = 4;

for i = 1:N_location_types
    for j = 1:N_locations_per_type(i)
        if i == location_CPIOM % CPIOM installation location type
            location_available_resources.area = 5;
            locations_type = i;
            
            locations{j} = ...
               Location(location_available_resources, locations_type);
        elseif i == location_CRDC % CRDC installation location type
            location_available_resources.area = 20;
            locations_type = i;
            
            locations{sum(N_locations_per_type(1:i-1)) + j} = ...
               Location(location_available_resources, locations_type);
        elseif i == location_LRU % LRU installation location type
            location_available_resources.area = 20;
            locations_type = i;
            
            locations{sum(N_locations_per_type(1:i-1)) + j} = ...
               Location(location_available_resources, locations_type);  
        elseif i == location_Switch % Switch installation location type
            location_available_resources.area = 20;
            locations_type = i;
            
            locations{sum(N_locations_per_type(1:i-1)) + j} = ...
               Location(location_available_resources, locations_type);  
        end
    end
end

