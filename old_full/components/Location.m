classdef Location
    %LOCATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        available_area;
        % type 1: CRDC installation location
        % type 2: CPIOM installation location (Avionics Compartment)
        location_type;
    end
    
    methods
        function obj = Location(available_resources, location_type)
            %LOCATION Construct an instance of this class
            %   Detailed explanation goes here
            obj.available_area = available_resources.area;
            obj.location_type = location_type;
        end
    end
end

