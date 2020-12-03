sw_ind = 1:N_softwares;
hw_ind = 1:N_hardwares;
location_ind = 1:N_locations;

SW_Avionics_H_ind = [];
SW_Avionics_J_ind = [];
SW_Allocator_H_ind = [];
SW_Allocator_J_ind = [];
SW_Status_Check_H_ind = [];
SW_Status_Check_J_ind = [];
SW_Data_Acquisition_ind = [];
SW_LRU_ind = [];
SW_Switch_ind = [];
for i = 1:N_softwares                
    if softwares{i,1}.software_type == SW_Avionics_H % Avionics-H
        SW_Avionics_H_ind = [SW_Avionics_H_ind i];
    elseif softwares{i,1}.software_type == SW_Avionics_J % Avionics-J
        SW_Avionics_J_ind = [SW_Avionics_J_ind i];
    elseif softwares{i,1}.software_type == SW_Allocator_H % Allocator H
        SW_Allocator_H_ind = [SW_Allocator_H_ind i];
    elseif softwares{i,1}.software_type == SW_Allocator_J % Allocator J
        SW_Allocator_J_ind = [SW_Allocator_J_ind i];
    elseif softwares{i,1}.software_type == SW_Status_check_H % Status check H
        SW_Status_Check_H_ind = [SW_Status_Check_H_ind i];
    elseif softwares{i,1}.software_type == SW_Status_check_J % Status check J
        SW_Status_Check_J_ind = [SW_Status_Check_J_ind i];
    elseif softwares{i,1}.software_type == SW_Data_acquisition % Data acquisiton
        SW_Data_Acquisition_ind = [SW_Data_Acquisition_ind i];
    elseif softwares{i,1}.software_type == SW_LRU % LRU
        SW_LRU_ind = [SW_LRU_ind i];
    elseif softwares{i,1}.software_type == SW_Switch % Switch
        SW_Switch_ind = [SW_Switch_ind i];
    end
end

HW_CPIOM_H_ind = [];
HW_CPIOM_J_ind = [];
HW_CRDC_A_ind = [];
HW_CRDC_B_ind = [];
HW_LRU_ind = [];
HW_Switch_ind = [];
for i = 1:N_hardwares
    if hardwares{i,1}.hardware_type == HW_CPIOM_H % CPIOM-H
        HW_CPIOM_H_ind = [HW_CPIOM_H_ind i];
    elseif hardwares{i,1}.hardware_type == HW_CPIOM_J % CPIOM-J
        HW_CPIOM_J_ind = [HW_CPIOM_J_ind i];    
    elseif hardwares{i,1}.hardware_type == HW_CRDC_A % CRDC-A
        HW_CRDC_A_ind = [HW_CRDC_A_ind i];
    elseif hardwares{i,1}.hardware_type == HW_CRDC_B % CRDC-B
        HW_CRDC_B_ind = [HW_CRDC_B_ind i];
    elseif hardwares{i,1}.hardware_type == HW_LRU % AFDX link
        HW_LRU_ind = [HW_LRU_ind i];
    elseif hardwares{i,1}.hardware_type == HW_Switch % Switch
        HW_Switch_ind = [HW_Switch_ind i];
    end
end

location_CPIOM_ind = [];
location_CRDC_ind = [];
location_LRU_ind = [];
location_Switch_ind = [];
for i = 1:N_locations
    if locations{i,1}.location_type == location_CPIOM
        location_CPIOM_ind = [location_CPIOM_ind i];
    elseif locations{i,1}.location_type == location_CRDC
        location_CRDC_ind = [location_CRDC_ind i];
    elseif locations{i,1}.location_type == location_LRU
        location_LRU_ind = [location_LRU_ind i];
    elseif locations{i,1}.location_type == location_Switch
        location_Switch_ind = [location_Switch_ind i];
    end
end