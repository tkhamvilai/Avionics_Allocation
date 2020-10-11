%%
disp('Start CVX formulation...')
tic

cvx_solver_settings( 'MIPGap', 0.02/100 );
cvx_begin    
    % X_sw2hw(i,j) = 1 means SW i is allocated to HW j
    variable X_sw2hw(N_softwares, N_hardwares) binary
    
    % X_hw2l(i,j) = 1 means HW i is allocated to location j
    variable X_hw2l(N_hardwares, N_locations) binary
    
    % X_sw2l(i,j) = 1 means SW i is allocated to location j
    variable X_sw2l(N_softwares, N_locations)
    variable X_sw2l_aux(N_softwares, N_locations, N_hardwares)
    
    % X_sw2s(i,j) = 1 means SW i is connected to Switch j
    variable X_sw2s(N_softwares + N_LRUs, N_switches)
    
    % X_hw(i) = 1 means HW i is used
    variable X_hw(N_hardwares)
    
    % X_ptl(i,j,k) means physical link i is used by task i from location j
%     variable X_ptl(N_links, N_softwares_per_type(SW_Avionics_H)+N_softwares_per_type(SW_Avionics_J)+N_softwares_per_type(SW_Allocator)+N_softwares_per_type(SW_Status_check), N_softwares_per_type(SW_Data_acquisition)) binary
%     expression Y(N_links, N_softwares_per_type(SW_Avionics_H)+N_softwares_per_type(SW_Avionics_J)+N_softwares_per_type(SW_Allocator)+N_softwares_per_type(SW_Status_check), N_softwares_per_type(SW_Data_acquisition))
 
%     minimize( sum(X_hw([HW_CRDC_A_ind HW_CRDC_B_ind])) + ...
%               avg_abs_dev(sum(X_sw2hw(SW_Avionics_H_ind, HW_CPIOM_H_ind))) + ...
%               avg_abs_dev(sum(X_sw2hw(SW_Avionics_J_ind, HW_CPIOM_J_ind))) + ...
%               sum(sum(W_sw2l.*X_sw2l)) )
    minimize( sum(X_hw) + sum(sum(W_sw2l.*X_sw2l)) )
    subject to
        % boundary constraint for variables that need not to be binary
        % for faster computational
        0 <= X_sw2l <= 1
        0 <= X_sw2l_aux <= 1
        0 <= X_sw2s <= 1
        0 <= X_hw <= 1        
        
        % allocation constraint
        sum(X_sw2hw,2) == 1; % every SW must be allocated to a HW
        sum(X_hw2l,2) == X_hw; % HW that is used to must be allocated to a location
        sum(X_hw2l) >= 1; % each location must host at least one HW
        % All CPIOMs must host at least two Avionics apps
        sum(X_sw2hw(SW_Avionics_H_ind, HW_CPIOM_H_ind)) >= 2;
        sum(X_sw2hw(SW_Avionics_J_ind, HW_CPIOM_J_ind)) >= 2;
        
        % type constraint        
        X_sw2hw(SW_Avionics_H_ind, setdiff(hw_ind,HW_CPIOM_H_ind)) == 0;
        X_sw2hw(SW_Avionics_J_ind, setdiff(hw_ind,HW_CPIOM_J_ind)) == 0;
        X_sw2hw(SW_Allocator_ind, setdiff(hw_ind,[HW_CPIOM_H_ind HW_CPIOM_J_ind])) == 0;
        X_sw2hw(SW_Status_Check_ind, setdiff(hw_ind,[HW_CPIOM_H_ind HW_CPIOM_J_ind])) == 0;
        X_sw2hw(SW_Data_Acquisition_ind, setdiff(hw_ind,[HW_CRDC_A_ind HW_CRDC_B_ind])) == 0;
%         X_sw2hw(SW_LRU_ind, setdiff(hw_ind,HW_LRU_ind)) == 0;
%         X_sw2hw(SW_Switch_ind, setdiff(hw_ind,HW_Switch_ind)) == 0;
        
        X_hw2l(HW_CPIOM_H_ind, setdiff(location_ind,location_CPIOM_ind)) == 0;
        X_hw2l(HW_CPIOM_J_ind, setdiff(location_ind,location_CPIOM_ind)) == 0;
        X_hw2l([HW_CRDC_A_ind HW_CRDC_B_ind], setdiff(location_ind,location_CRDC_ind)) == 0;       
%         X_hw2l(HW_LRU_ind, setdiff(location_ind,location_LRU_ind)) == 0;
%         X_hw2l(HW_Switch_ind, setdiff(location_ind,location_Switch_ind)) == 0;
        
        % segregation constraint 
        % TODO: based on redundancy type
        % only 1 Status Check app can be allocated to the same CPIOM
        sum(X_sw2hw(SW_Status_Check_ind, HW_CPIOM_H_ind)) == 1;
        sum(X_sw2hw(SW_Status_Check_ind, HW_CPIOM_J_ind)) == 1;
        % at least 3 Allocator app must be allocated to the same CPIOM type
        sum(sum(X_sw2hw(SW_Allocator_ind, HW_CPIOM_H_ind))) >= 3;
        sum(sum(X_sw2hw(SW_Allocator_ind, HW_CPIOM_J_ind))) >= 3;        
        % at most 1 Allocator app can be allocated to the same CPIOM
        sum(X_sw2hw(SW_Allocator_ind, HW_CPIOM_H_ind)) <= 1;
        sum(X_sw2hw(SW_Allocator_ind, HW_CPIOM_J_ind)) <= 1; 
%         % only 1 LRU app can be allocated to the LRU
%         sum(X_sw2hw(SW_LRU_ind, HW_LRU_ind)) == 1;
%         % only 1 switch app can be allocated to the switch
%         sum(X_sw2hw(SW_Switch_ind, HW_Switch_ind)) == 1;
%         % only 1 switch can be allocated to the same location
%         sum(X_hw2l(HW_Switch_ind, location_Switch_ind)) == 1;     
        
        % HW usages  
        repmat(X_hw', N_softwares, 1) >= X_sw2hw;
        X_hw(HW_CPIOM_H_ind) == 1; % All CPIOM-H must be used
        X_hw(HW_CPIOM_J_ind) == 1; % All CPIOM-J must be used
%         X_hw(HW_LRU_ind) == 1; % All LRUs must be used
%         X_hw(HW_Switch_ind) == 1; % All Switches must be used
        
        % resource constraint
        SW_required_resources*X_sw2hw <= HW_available_resources;
        HW_required_resources*X_hw2l <= Location_available_resources;
        
        % linearization of X_sw2l = X_sw2hw*X_hw2l
        X_sw2l([SW_Avionics_H_ind SW_Avionics_J_ind SW_Allocator_ind SW_Status_Check_ind],location_CPIOM) == 1;
        X_sw2l([SW_Avionics_H_ind SW_Avionics_J_ind SW_Allocator_ind SW_Status_Check_ind],setdiff(location_ind,location_CPIOM)) == 0;
        X_sw2l(SW_LRU_ind,location_LRU) == 1;
        X_sw2l(SW_LRU_ind,setdiff(location_ind,location_LRU)) == 0;
        X_sw2l(SW_Switch_ind,location_Switch) == 1;
        X_sw2l(SW_Switch_ind,setdiff(location_ind,location_Switch)) == 0;
        
        X_sw2l_aux <= permute(repmat(X_sw2hw,1,1,N_locations), [1 3 2]);
        X_sw2l_aux <= permute(repmat(X_hw2l,1,1,N_softwares), [3 2 1]);
        X_sw2l_aux >= permute(repmat(X_sw2hw,1,1,N_locations), [1 3 2]) + permute(repmat(X_hw2l,1,1,N_softwares), [3 2 1]) - 1; 
        X_sw2l == sum(X_sw2l_aux,3);
        
%         for k = 1:N_hardwares
%             X_sw2l >= repmat(X_sw2hw(:,k),1,N_locations) + repmat(X_hw2l(k,:),N_softwares,1) - 1;
%         end

%         for i = SW_Data_Acquisition_ind
%             for j = location_CRDC_ind
%                 [i,j]
%                 X_sw2l(i,j) >= X_sw2hw(i,:) + X_hw2l(:,j)' - 1;
%                 for k = 1:N_hardwares
%                 X_sw2l(i,j) >= X_sw2hw(i,k) + X_hw2l(k,j) - 1;
%                 end
%             end
%         end

        % bandwidth constraint
        X_sw2s(SW_Avionics_H_ind,:) == X_sw2hw(SW_Avionics_H_ind,HW_CPIOM_H_ind)*X_CPIOM_H2s;
        X_sw2s(SW_Avionics_J_ind,:) == X_sw2hw(SW_Avionics_J_ind,HW_CPIOM_J_ind)*X_CPIOM_J2s;
        X_sw2s(SW_Allocator_ind,:) == X_sw2hw(SW_Allocator_ind,[HW_CPIOM_H_ind HW_CPIOM_J_ind])*[X_CPIOM_H2s;X_CPIOM_J2s];
        X_sw2s(SW_Status_Check_ind,:) == X_sw2hw(SW_Status_Check_ind,[HW_CPIOM_H_ind HW_CPIOM_J_ind])*[X_CPIOM_H2s;X_CPIOM_J2s];
        X_sw2s(SW_Data_Acquisition_ind,:) == X_sw2l(SW_Data_Acquisition_ind,location_CRDC_ind)*X_CRDC_l2s;
        X_sw2s(end-N_LRUs+1:end,:) == X_LRU2s;
cvx_end
cvx_clear
cvx_solver_settings -clear

model_and_solve_time = toc;
disp('Finished solving problem...')

X_sw2hw = full(X_sw2hw);
X_hw2l = full(X_hw2l);
X_sw2l = full(X_sw2l);
X_hw = full(X_hw);
X_sw2s = full(X_sw2s);