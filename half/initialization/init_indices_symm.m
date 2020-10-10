sw_ind = 1:N_softwares_symm;
hw_ind = 1:N_hardwares_symm;
location_ind = 1:N_locations_symm;

Avionics_H_app_ind = [];
Avionics_J_app_ind = [];
Allocator_app_ind = [];
Status_Check_app_ind = [];
Data_Acquisiton_app_ind = [];
Switch_app_ind = [];
for i = 1:N_softwares_symm                
    if softwares{i,1}.software_type == SW_Avionics_H % Avionics-H
        Avionics_H_app_ind = [Avionics_H_app_ind i];
    elseif softwares{i,1}.software_type == SW_Avionics_J % Avionics-J
        Avionics_J_app_ind = [Avionics_J_app_ind i];
    elseif softwares{i,1}.software_type == SW_Allocator % Allocator
        Allocator_app_ind = [Allocator_app_ind i];
    elseif softwares{i,1}.software_type == SW_Status_check % Status check
        Status_Check_app_ind = [Status_Check_app_ind i];
    elseif softwares{i,1}.software_type == SW_Data_acquisition % Data acquisiton
        Data_Acquisiton_app_ind = [Data_Acquisiton_app_ind i];
    elseif softwares{i,1}.software_type == SW_Switch % Switch
        Switch_app_ind = [Switch_app_ind i];
    end
end

CPIOM_H_ind = [];
CPIOM_J_ind = [];
CRDC_A_ind = [];
CRDC_B_ind = [];
Switch_ind = [];
AFDX_link = [];
for i = 1:N_hardwares_symm
    if hardwares{i,1}.hardware_type == HW_CPIOM_H % CPIOM-H
        CPIOM_H_ind = [CPIOM_H_ind i];
    elseif hardwares{i,1}.hardware_type == HW_CPIOM_J % CPIOM-J
        CPIOM_J_ind = [CPIOM_J_ind i];
    elseif hardwares{i,1}.hardware_type == HW_Switch % Switch
        Switch_ind = [Switch_ind i];
    elseif hardwares{i,1}.hardware_type == HW_CRDC_A % CRDC-A
        CRDC_A_ind = [CRDC_A_ind i];
    elseif hardwares{i,1}.hardware_type == HW_CRDC_B % CRDC-B
        CRDC_B_ind = [CRDC_B_ind i];
    elseif hardwares{i,1}.hardware_type == HW_AFDX_link % AFDX link
        AFDX_link = [AFDX_link i];
    end
end

location_CRDC_ind = [];
location_CPIOM_ind = [];
for i = 1:N_locations_symm
    if locations{i,1}.location_type == location_CRDC
        location_CRDC_ind = [location_CRDC_ind i];
    elseif locations{i,1}.location_type == location_CPIOM
        location_CPIOM_ind = [location_CPIOM_ind i];
    end
end