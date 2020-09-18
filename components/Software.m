classdef Software
    %Software Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        required_memory; % per HW type
        required_IO; % per IO type, per HW type
        required_bandwidth; % per HW type
        % type 0: no redundancy requirement
        % type 1: SW cannot be allocated on the same HW
        % type 2: SW cannot be allocated on the same HW type (implies 1)
        % type 3: SW cannot be allocated at the same location (implies 1)
        % type 4: a combination of 2 and 3
        redundancy_type;
        % type 1: Processing SW
        % type 2: Allocator SW
        % type 3: Status check SW
        % type 4: Data acquisiton SW
        % type 5: Switch SW (run on Switch HW)
        % type 6: Communication SW (run on AFDX link HW)
        software_type;
    end
    
    methods
        function obj = Software(required_resources, redundancy_type, software_type)
            %Software Construct an instance of this class
            %   Detailed explanation goes here
            obj.required_memory = required_resources.memory;
            obj.required_IO = required_resources.IO;
            obj.required_bandwidth = required_resources.bandwidth;
            obj.redundancy_type = redundancy_type;
            obj.software_type = software_type;
        end
    end
end

