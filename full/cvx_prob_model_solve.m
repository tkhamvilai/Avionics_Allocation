%%
disp('Start CVX formulation...')
tic

cvx_solver_settings( 'MIPGap', 0.1/100 );
cvx_begin    
    % X_sw2hw(i,j) = 1 means SW i is allocated to HW j
    variable X_sw2hw(N_softwares, N_hardwares) binary
    
    % X_hw2l(i,j) = 1 means HW i is allocated to location j
    variable X_hw2l(N_hardwares, N_locations) binary
    
    % X_sw2l(i,j) = 1 means SW i is allocated to location j
    variable X_sw2l(N_softwares_per_type(SW_Data_acquisition), N_locations_per_type(location_CRDC)) binary
    variable X_sw2l_aux(N_softwares_per_type(SW_Data_acquisition), N_locations_per_type(location_CRDC), N_hardwares_per_type(HW_CRDC_A)+N_hardwares_per_type(HW_CRDC_B)) binary
    
    % X_sw2s(i,j) = 1 means SW i is connected to Switch j
    variable X_sw2s(N_softwares + N_LRUs, N_switches) binary
    
    % X_hw(i) = 1 means HW i is used
    variable X_hw(N_hardwares) binary
    
    % X_ptl(i,j,k) means physical link i is used for sending data from SW j to SW k
    variable X_ptl(N_links, N_softwares + N_LRUs, N_softwares + N_LRUs) integer
    expression Y(N_links, N_softwares + N_LRUs, N_softwares + N_LRUs)
%     variable X_ptl(N_links, N_softwares_per_type(SW_Avionics_H)+N_softwares_per_type(SW_Avionics_J)+N_softwares_per_type(SW_Allocator_H)+N_softwares_per_type(SW_Allocator_J), N_softwares_per_type(SW_Data_acquisition)+ + N_LRUs+N_softwares_per_type(SW_Status_check_H)+N_softwares_per_type(SW_Status_check_J)) binary
%     expression Y(N_links, N_softwares_per_type(SW_Avionics_H)+N_softwares_per_type(SW_Avionics_J)+N_softwares_per_type(SW_Allocator_H)+N_softwares_per_type(SW_Allocator_J), N_softwares_per_type(SW_Data_acquisition)+ + N_LRUs+N_softwares_per_type(SW_Status_check_H)+N_softwares_per_type(SW_Status_check_J))
 
%     minimize( sum(X_hw([HW_CRDC_A_ind HW_CRDC_B_ind])) + ...
%               avg_abs_dev(sum(X_sw2hw(SW_Avionics_H_ind, HW_CPIOM_H_ind))) + ...
%               avg_abs_dev(sum(X_sw2hw(SW_Avionics_J_ind, HW_CPIOM_J_ind))) + ...
%               sum(sum(W_sw2l.*X_sw2l)) )
    minimize( sum(X_hw) + sum(sum(W_sw2l(SW_Data_Acquisition_ind,location_CRDC_ind).*X_sw2l)) )
%     minimize( sum(X_hw) )
%     minimize( sum(X_hw) + sum(sum(W_sw2l(SW_Data_Acquisition_ind,location_CRDC_ind).*X_sw2l)) + sum(sum(sum(X_ptl))) )
    subject to
        % boundary constraint for variables that need not to be binary
        % for faster computational
%         0 <= X_sw2l <= 1
%         0 <= X_sw2l_aux <= 1
%         0 <= X_sw2s <= 1
%         0 <= X_hw <= 1        
        
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
        X_sw2hw(SW_Allocator_H_ind, setdiff(hw_ind,HW_CPIOM_H_ind)) == 0;
        X_sw2hw(SW_Allocator_J_ind, setdiff(hw_ind,HW_CPIOM_J_ind)) == 0;
        X_sw2hw(SW_Status_Check_H_ind, setdiff(hw_ind,HW_CPIOM_H_ind)) == 0;
        X_sw2hw(SW_Status_Check_J_ind, setdiff(hw_ind,HW_CPIOM_J_ind)) == 0;
        X_sw2hw(SW_Data_Acquisition_ind, setdiff(hw_ind,[HW_CRDC_A_ind HW_CRDC_B_ind])) == 0;
        
        X_hw2l(HW_CPIOM_H_ind, setdiff(location_ind,location_CPIOM_ind)) == 0;
        X_hw2l(HW_CPIOM_J_ind, setdiff(location_ind,location_CPIOM_ind)) == 0;
        X_hw2l([HW_CRDC_A_ind HW_CRDC_B_ind], setdiff(location_ind,location_CRDC_ind)) == 0;
        
        % segregation constraint 
        % TODO: based on redundancy type
        % only 1 Status Check app can be allocated to the same CPIOM
        sum(X_sw2hw(SW_Status_Check_H_ind, HW_CPIOM_H_ind)) == 1;
        sum(X_sw2hw(SW_Status_Check_J_ind, HW_CPIOM_J_ind)) == 1;
        % at least 3 Allocator app must be allocated to the same CPIOM type
%         sum(sum(X_sw2hw(SW_Allocator_ind, HW_CPIOM_H_ind))) >= 3;
%         sum(sum(X_sw2hw(SW_Allocator_ind, HW_CPIOM_J_ind))) >= 3;        
        % at most 1 Allocator app can be allocated to the same CPIOM
        sum(X_sw2hw(SW_Allocator_H_ind, HW_CPIOM_H_ind)) <= 1;
        sum(X_sw2hw(SW_Allocator_J_ind, HW_CPIOM_J_ind)) <= 1;   
        
        % HW usages  
        repmat(X_hw', N_softwares, 1) >= X_sw2hw;
        X_hw(HW_CPIOM_H_ind) == 1; % All CPIOM-H must be used
        X_hw(HW_CPIOM_J_ind) == 1; % All CPIOM-J must be used
        
        % resource constraint
        SW_required_resources*X_sw2hw <= HW_available_resources;
        HW_required_resources*X_hw2l <= Location_available_resources;
        
        % linearization of X_sw2l = X_sw2hw*X_hw2l        
        X_sw2l_aux <= permute(repmat(X_sw2hw(SW_Data_Acquisition_ind,[HW_CRDC_A_ind HW_CRDC_B_ind]),1,1,N_locations_per_type(location_CRDC)), [1 3 2]);
        X_sw2l_aux <= permute(repmat(X_hw2l([HW_CRDC_A_ind HW_CRDC_B_ind], location_CRDC_ind),1,1,N_softwares_per_type(SW_Data_acquisition)), [3 2 1]);
        X_sw2l_aux >= permute(repmat(X_sw2hw(SW_Data_Acquisition_ind,[HW_CRDC_A_ind HW_CRDC_B_ind]),1,1,N_locations_per_type(location_CRDC)), [1 3 2]) + ...
            permute(repmat(X_hw2l([HW_CRDC_A_ind HW_CRDC_B_ind], location_CRDC_ind),1,1,N_softwares_per_type(SW_Data_acquisition)), [3 2 1]) - 1; 
        X_sw2l == sum(X_sw2l_aux,3);

        % bandwidth constraint
        X_sw2s(SW_Avionics_H_ind,:) == X_sw2hw(SW_Avionics_H_ind,HW_CPIOM_H_ind)*X_CPIOM_H2s;
        X_sw2s(SW_Avionics_J_ind,:) == X_sw2hw(SW_Avionics_J_ind,HW_CPIOM_J_ind)*X_CPIOM_J2s;
        X_sw2s(SW_Allocator_H_ind,:) == X_sw2hw(SW_Allocator_H_ind,HW_CPIOM_H_ind)*X_CPIOM_H2s;
        X_sw2s(SW_Allocator_J_ind,:) == X_sw2hw(SW_Allocator_J_ind,HW_CPIOM_J_ind)*X_CPIOM_J2s;
        X_sw2s(SW_Status_Check_H_ind,:) == X_sw2hw(SW_Status_Check_H_ind,HW_CPIOM_H_ind)*X_CPIOM_H2s;
        X_sw2s(SW_Status_Check_J_ind,:) == X_sw2hw(SW_Status_Check_J_ind,HW_CPIOM_J_ind)*X_CPIOM_J2s;
        X_sw2s(SW_Data_Acquisition_ind,:) == X_sw2l*X_CRDC_l2s;
        X_sw2s(end-N_LRUs+1:end,:) == X_LRU2s;        
        
        for n = 1:nnz(G_sw)
            i = G_sw_i(n); % source index
            j = G_sw_j(n); % sink index
            % source-sink vectors
            % (X_sw2s(i,:))' means if sw_i->switch s, switch s is a source
            % (X_sw2s(j,:))' means if sw_j->switch s, switch s is a sink
            % G_es*X_ptl(:,i,j) is a vector with the size of N_links
            G_es*X_ptl(:,i,j) == (X_sw2s(i,:))' - (X_sw2s(j,:))';
            Y(:,i,j) = 1*X_ptl(:,i,j);
        end
        % sum(Y,3) is the usage of p_link bandwidth from each source (sum over sink)
        % sum(sum(Y,3),2) is the total usage of p_link bandwidth by all sources (sum over sink, then source)
        sum(sum(Y,3),2) <= 1000;
        
%         for i = 1:N_softwares_per_type(SW_Avionics_H)+N_softwares_per_type(SW_Avionics_J)+N_softwares_per_type(SW_Allocator) % for each source task
%             for j = 1:N_softwares_per_type(SW_Status_check)+N_softwares_per_type(SW_Data_acquisition) % for each sink task
%                 if i ~= j && G_t(i,j) == 1 % source i, sink j
%                     % source-sink vectors
%                     % (X_t2l(i,:))' means if t_i->l, l is a source
%                     % (X_t2l(j,:))' means if t_j->l, l is a sink
%                     % G_l*X_ptl(:,i,j) is a vector with the size of N_p_link
%                     % each element indicates the usage of the p_link
%                     G_l*X_ptl(:,i,j) == (X_t2l(i,:))' - (X_t2l(j,:))';
%                     % bandwidth used for each p_link
%                     Y(:,i,j) = R_r_b(i,j)*X_ptl(:,i,j);
%                 end
%             end
%         end      
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