classdef Hardware
    %HARDWARE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        available_memory;
        available_IO;
        available_bandwidth;
        required_area;
        % type 0: no redundancy requirement
        % type 1: HW cannot be placed at the same location
        % type 2: HW must be placed at the same location
        redundancy_type;
        % type 1: CPIOM-H
        % type 2: CPIOM-J
        % type 3: Switch
        % type 4: CRDC-A
        % type 5: CRDC-B
        % type 6: AFDX link
        hardware_type;
    end
    
    methods
        function obj = Hardware(available_resources, required_resources, redundancy_type, hardware_type)
            %HARDWARE Construct an instance of this class
            %   Detailed explanation goes here
            obj.available_memory = available_resources.memory;
            obj.available_IO = available_resources.IO;
            obj.available_bandwidth = available_resources.bandwidth;
            obj.required_area = required_resources.area;
            obj.redundancy_type = redundancy_type;
            obj.hardware_type = hardware_type;
        end
    end
end

