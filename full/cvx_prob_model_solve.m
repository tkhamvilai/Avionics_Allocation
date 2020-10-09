%%
disp('Start CVX formulation...')
tic

cvx_solver_settings( 'MIPGap', 0.01/100 );
cvx_begin    
    % X_sw2hw(i,j) = 1 means SW i is allocated to HW j
    variable X_sw2hw(N_softwares_symm, N_hardwares_symm) binary
    
    % X_hw2l(i,j) = 1 means HW i is allocated to location j
    variable X_hw2l(N_hardwares_symm, N_locations_symm) binary
    
    % X_sw2l(i,j) = 1 means SW i is allocated to location j
    variable X_sw2l(N_softwares_symm, N_locations_symm) binary
    variable X_sw2l_aux(N_softwares_symm, N_locations_symm, N_hardwares_symm) binary
    
    % X_hw(i) = 1 means HW i is used
    variable X_hw(N_hardwares_symm) binary;
    
    % X_ptl(i,j,k) means physical link i is used by task i from location j
%     variable X_ptl(N_hardwares_per_type_symm(HW_AFDX_link), N_softwares_per_type_symm(SW_Avionics_H)+N_softwares_per_type_symm(SW_Avionics_J)+N_softwares_per_type_symm(SW_Allocator)+N_softwares_per_type_symm(SW_Status_check), N_softwares_per_type_symm(SW_Data_acquisition)) binary
%     expression Y(N_hardwares_per_type_symm(HW_AFDX_link), N_softwares_per_type_symm(SW_Avionics_H)+N_softwares_per_type_symm(SW_Avionics_J)+N_softwares_per_type_symm(SW_Allocator)+N_softwares_per_type_symm(SW_Status_check), N_softwares_per_type_symm(SW_Data_acquisition))
 
%     minimize( sum(X_hw([CRDC_A_ind CRDC_B_ind])) + ...
%               avg_abs_dev(sum(X_sw2hw(Avionics_H_app_ind, CPIOM_H_ind))) + ...
%               avg_abs_dev(sum(X_sw2hw(Avionics_J_app_ind, CPIOM_J_ind))) + ...
%               sum(sum(W.*X_sw2l)) )
    minimize( sum(X_hw) + sum(sum(W.*X_sw2l)) )
    subject to
        % allocation constraint
        sum(X_sw2hw,2) == 1; % every SW must be allocated to a HW
        sum(X_hw2l,2) == X_hw; % HW that has SW allocated to must be allocated to a location
        sum(X_hw2l) >= 1; % each location must host at least one HW
        % All CPIOMs must host at least two Avionics apps
        sum(X_sw2hw(Avionics_H_app_ind, CPIOM_H_ind)) >= 2;
        sum(X_sw2hw(Avionics_J_app_ind, CPIOM_J_ind)) >= 2;
        
        % type constraint        
        X_sw2hw(Avionics_H_app_ind, setdiff(hw_ind,CPIOM_H_ind)) == zeros(size(X_sw2hw(Avionics_H_app_ind, setdiff(hw_ind,CPIOM_H_ind))));
        X_sw2hw(Avionics_J_app_ind, setdiff(hw_ind,CPIOM_J_ind)) == zeros(size(X_sw2hw(Avionics_J_app_ind, setdiff(hw_ind,CPIOM_J_ind))));
        X_sw2hw(Allocator_app_ind, setdiff(hw_ind,[CPIOM_H_ind CPIOM_J_ind])) == zeros(size(X_sw2hw(Allocator_app_ind, setdiff(hw_ind,[CPIOM_H_ind CPIOM_J_ind]))));
        X_sw2hw(Status_Check_app_ind, setdiff(hw_ind,[CPIOM_H_ind CPIOM_J_ind])) == zeros(size(X_sw2hw(Status_Check_app_ind, setdiff(hw_ind,[CPIOM_H_ind CPIOM_J_ind]))));
        X_sw2hw(Data_Acquisiton_app_ind, setdiff(hw_ind,[CRDC_A_ind CRDC_B_ind])) == zeros(size(X_sw2hw(Data_Acquisiton_app_ind, setdiff(hw_ind,[CRDC_A_ind CRDC_B_ind]))));
        X_sw2hw(Switch_app_ind, setdiff(hw_ind,Switch_ind)) == zeros(size(X_sw2hw(Switch_app_ind, setdiff(hw_ind,Switch_ind))));
        
        X_hw2l(CPIOM_H_ind, setdiff(location_ind,location_CPIOM_ind)) == zeros(size(X_hw2l(CPIOM_H_ind, setdiff(location_ind,location_CPIOM_ind))));
        X_hw2l(CPIOM_J_ind, setdiff(location_ind,location_CPIOM_ind)) == zeros(size(X_hw2l(CPIOM_J_ind, setdiff(location_ind,location_CPIOM_ind))));
        X_hw2l([CRDC_A_ind CRDC_B_ind], setdiff(location_ind,location_CRDC_ind)) == zeros(size(X_hw2l([CRDC_A_ind CRDC_B_ind], setdiff(location_ind,location_CRDC_ind))));       
        
        % segregation constraint 
        % TODO: based on redundancy type
        % only 1 Status Check app can be allocated to the same CPIOM
        sum(X_sw2hw(Status_Check_app_ind, CPIOM_H_ind)) == 1;
        sum(X_sw2hw(Status_Check_app_ind, CPIOM_J_ind)) == 1;
        % at least 3 Allocator app must be allocated to the same CPIOM type
        sum(sum(X_sw2hw(Allocator_app_ind, CPIOM_H_ind))) >= 3;
        sum(sum(X_sw2hw(Allocator_app_ind, CPIOM_J_ind))) >= 3;        
        % at most 1 Allocator app can be allocated to the same CPIOM
        sum(X_sw2hw(Allocator_app_ind, CPIOM_H_ind)) <= 1;
        sum(X_sw2hw(Allocator_app_ind, CPIOM_J_ind)) <= 1;        
        % only 1 Switch app can be allocated to the same Switch
        sum(X_sw2hw(Switch_app_ind, Switch_ind)) == 1;
        % at most 1 switch can be allocated to the same location
        sum(X_sw2hw(Switch_ind, location_CRDC_ind)) <= 1;
        sum(X_sw2hw(Switch_ind, location_CPIOM_ind)) <= 1;
        
        % HW usages
        for i = 1:N_hardwares_symm
            X_hw(i) >= X_sw2hw(:,i);
        end        
        X_hw(CPIOM_H_ind) == 1; % All CPIOM-H must be used
        X_hw(CPIOM_J_ind) == 1; % All CPIOM-J must be used
        
        % resource constraint
        SW_required_resources*X_sw2hw <= HW_available_resources;
        HW_required_resources*X_hw2l <= Location_available_resources;
        
        % linearization of X_sw2l = Xsw2hw*Xhw2l
        for i = 1:N_softwares_symm
            for j = 1:N_locations_symm 
                squeeze(X_sw2l_aux(i,j,:)) <= X_sw2hw(i,:)';
                squeeze(X_sw2l_aux(i,j,:)) <= X_hw2l(:,j);
                squeeze(X_sw2l_aux(i,j,:)) >= X_sw2hw(i,:)' + X_hw2l(:,j) - 1;
            end
        end
        X_sw2l == sum(X_sw2l_aux,3);
cvx_end
cvx_clear
cvx_solver_settings -clear

model_and_solve_time = toc;
disp('Finished solving problem...')

X_sw2hw = full(X_sw2hw);
X_hw2l = full(X_hw2l);
X_sw2l = full(X_sw2l);
X_hw = full(X_hw);