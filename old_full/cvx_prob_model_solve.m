%%
disp('Start CVX formulation...')
tic

% cvx_solver_settings( 'MIPGap', 0.5/100 );
cvx_begin    
    % X_sw2hw(i,j) = 1 means SW i is allocated to HW j
    variable X_sw2hw(N_softwares, N_hardwares) binary
    
    % X_hw2l(i,j) = 1 means HW i is allocated to location j
    variable X_hw2l(N_hardwares, N_locations) binary
    
    % X_sw2l(i,j) = 1 means SW i is allocated to location j
    variable X_sw2l(N_softwares, N_locations) binary
    variable X_sw2l_aux(N_softwares, N_locations, N_hardwares) binary
    
    % X_hw(i) = 1 means HW i is used
    variable X_hw(N_hardwares) binary;
    
    % sum of memory on all software that run on a HW
    expression softwares_required_memory(N_hardwares)
    
    % sum of IO on all software that run on a HW
    expression softwares_required_IO(N_hardwares)
    
    % sum of bandwidth on all software that run on a HW
    expression softwares_required_bandwidth(N_hardwares)
    
    % sum of area on all HW that placed on a location
    expression hardwares_required_area(N_locations)
    
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
        
        % allocation type constraint
        for i = 1:N_softwares
            for j = 1:N_hardwares
                
                % Avionics-H can be allocated to CPIOM-H only
                if softwares{i,1}.software_type == 1
                    if hardwares{j,1}.hardware_type ~= 1
                        X_sw2hw(i,j) == 0;
                    end
                    
                % Avionics-J can be allocated to CPIOM-J only
                elseif softwares{i,1}.software_type == 2
                    if hardwares{j,1}.hardware_type ~= 2
                        X_sw2hw(i,j) == 0;
                    end
                    
                % Allocator apps can be allocated to CPIOM only
                elseif softwares{i,1}.software_type == 3
                    if hardwares{j,1}.hardware_type ~= 1 && hardwares{j,1}.hardware_type ~= 2
                        X_sw2hw(i,j) == 0;
                    end
                    
                % Status Check apps can be allocated to CPIOM only
                elseif softwares{i,1}.software_type == 4
                    if hardwares{j,1}.hardware_type ~= 1 && hardwares{j,1}.hardware_type ~= 2
                        X_sw2hw(i,j) == 0;
                    end
                
                % Data acquisiton can be installed at CRDC only
                elseif softwares{i,1}.software_type == 5
                    if hardwares{j,1}.hardware_type ~= 4 && hardwares{j,1}.hardware_type ~= 5
                        X_sw2hw(i,j) == 0;
                    end

                elseif softwares{i,1}.software_type == 6 % Switch link
                    
                elseif softwares{i,1}.software_type == 7 % Communication link

                end
            end
        end
        
        for i = 1:N_hardwares
            for j = 1:N_locations
                
                % CPIOM can be installed at Avionics Compartment only
                if hardwares{i,1}.hardware_type == 1
                    if locations{j,1}.location_type == 1
                        X_hw2l(i,j) == 0;
                    end
                    
                elseif hardwares{i,1}.hardware_type == 2
                    if locations{j,1}.location_type == 1
                        X_hw2l(i,j) == 0;
                    end

                elseif hardwares{i,1}.hardware_type == 3 % Switch
                
                % CRDC can be installed at CRDC location only
                elseif hardwares{i,1}.hardware_type == 4 || hardwares{i,1}.hardware_type == 5
                    if locations{j,1}.location_type == 2
                        X_hw2l(i,j) == 0;
                    end

                elseif hardwares{i,1}.hardware_type == 6 % AFDX link

                end
            end
        end
        
        % segregation constraint
        % only 1 Status Check app can be allocated to the same CPIOM
        sum(X_sw2hw(Status_Check_app_ind, CPIOM_H_ind)) == 1;
        sum(X_sw2hw(Status_Check_app_ind, CPIOM_J_ind)) == 1;

        % at least 3 Allocator app must be allocated to the same CPIOM type
        sum(sum(X_sw2hw(Allocator_app_ind, CPIOM_H_ind))) >= 3;
        sum(sum(X_sw2hw(Allocator_app_ind, CPIOM_J_ind))) >= 3;
        
        % at most 1 Allocator app can be allocated to the same CPIOM
        sum(X_sw2hw(Allocator_app_ind, CPIOM_H_ind)) <= 1;
        sum(X_sw2hw(Allocator_app_ind, CPIOM_J_ind)) <= 1;
        
        % HW usages
        for i = 1:N_hardwares
            for j = 1:N_softwares
                X_hw(i) >= X_sw2hw(j,i);
            end
        end        
        X_hw(CPIOM_H_ind) == 1; % All CPIOM-H must be used
        X_hw(CPIOM_J_ind) == 1; % All CPIOM-J must be used
        
        % resource constraint
        for i = 1:N_hardwares
            for j = 1:N_softwares
                softwares_required_memory(i) = softwares_required_memory(i) + ...
                    softwares{j,1}.required_memory*X_sw2hw(j,i);
                
                softwares_required_IO(i) = softwares_required_IO(i) + ...
                    length(softwares{j,1}.required_IO)*X_sw2hw(j,i);
                
                softwares_required_bandwidth(i) = softwares_required_bandwidth(i) + ...
                    softwares{j,1}.required_bandwidth*X_sw2hw(j,i);
            end
            softwares_required_memory(i) <= hardwares{i,1}.available_memory;
            softwares_required_IO(i) <= hardwares{i,1}.available_IO;
            softwares_required_bandwidth(i) <= hardwares{i,1}.available_bandwidth;
        end
        
        for i = 1:N_locations
            for j = 1:N_hardwares
                hardwares_required_area(i) = hardwares_required_area(i) + ...
                    hardwares{j,1}.required_area*X_hw2l(j,i);
            end
            hardwares_required_area(i) <= locations{i,1}.available_area;
        end
        
        % linearization of X_sw2l = Xsw2hw*Xhw2l
        for i = 1:N_softwares
            for j = 1:N_locations 
                for k = 1:N_hardwares
                    X_sw2l_aux(i,j,k) <= X_sw2hw(i,k);
                    X_sw2l_aux(i,j,k) <= X_hw2l(k,j);
                    X_sw2l_aux(i,j,k) >= X_sw2hw(i,k) + X_hw2l(k,j) - 1;
                end
                X_sw2l(i,j) == sum(X_sw2l_aux(i,j,:));
            end
        end
cvx_end
cvx_clear
cvx_solver_settings -clear

model_and_solve_time = toc;
disp('Finished solving problem...')

X_sw2hw = full(X_sw2hw);
X_hw2l = full(X_hw2l);
% X_sw2l = full(X_sw2l);
X_hw = full(X_hw);