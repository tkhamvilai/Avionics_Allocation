clc; clear; close all

% cvx_solver Gurobi_2
% cvx_save_prefs

%% Input Parameters
N_l = 5; % the number of locations
N_d = 16; % the number of end-devices
N_t = 6; % the number of tasks
N_idle_t = N_d; % the number of idle tasks
N_s = 3; % the number of switches per location
N_p_link = 4; % the number of physical links connecting swithces

% topology matrix of switches and physical links (N_switches x N_p_link)
G_l = [ 1  1  1  1; % incident matrix between switches and physical links
       -1  0  0  0; % 1 pointing out of the switch
        0 -1  0  0; % -1 pointing into the switch
        0  0 -1  0;
        0  0  0 -1];
    
% task communication matrix
G_t = [0 1 1 1 1 0 zeros(1,N_idle_t); % flight controller requires data from sensors / actuators
       zeros(4,N_t + N_idle_t); % sensors / actuators
       zeros(1,N_t) ones(1,N_idle_t); % allocator requires data from all
       zeros(N_idle_t, N_t-1) ones(N_idle_t, 1) ...
       zeros(N_idle_t, N_idle_t)]; % idle tasks
non_sensor_actuator_idle_t = [1; zeros(4,1); 1; zeros(N_idle_t,1)]; % index of non sensor/actuator/idle tasks

R_a_ld = 4*ones(N_l,1); % available space resources at each location
R_r_ld = ones(N_d,1); % required space resources for each device
R_a_dt = 2*ones(N_d,1); % available CPU resources for each device
R_r_dt = ones(N_t + N_idle_t,1); % required CPU resources for each task
R_a_b = 50*ones(N_p_link,1); % available bandwidth resources for each physical link
R_r_b = 2*G_t; % required bandwidth resources for each communication

%% Problem Formulation
cvx_begin
    % X_t2d(i,j) = 1 means task i is allocated to device j
    variable X_t2d(N_t + N_idle_t, N_d) binary
    
    % X_d2l(i,j) = 1 means device i is allocated to location j
    variable X_d2l(N_d, N_l) binary
    
    % X_t2l(i,j) = 1 means task i is allocated to location j
    variable X_t2l(N_t + N_idle_t, N_l) binary
    variable X_t2l_ij(N_t + N_idle_t, N_l, N_d) binary % aux
    
    % X_ptl(i,j,k) means physical link i is used by task i from location j
    variable X_ptl(N_p_link, N_t + N_idle_t, N_t + N_idle_t) binary
    expression Y(N_p_link, N_t + N_idle_t, N_t + N_idle_t)
    
%     minimize sum(sum(X_d2l)) + sum(sum(X_t2d))% + sum(sum(sum(sum(sum(X_tdv)))))
    minimize avg_abs_dev(sum(X_d2l))
    subject to
        % allocation constraint
        sum(X_t2d,2) == 1; % every task must be allocated to a device
        R_r_dt'*X_t2d <= R_a_dt'; % each device can hold tasks up to its resources
        sum(X_d2l,2) == 1; % every device must be allocated to a location
        R_r_ld'*X_d2l <= R_a_ld'; % each location can hold devices up to its resources    
        sum(X_t2d(N_t+1:end,:),1) == 1; % each device must hold one idle task for health check
        % end allocation constraint
        
        % linearization of X_t2l = Xt2d*Xd2l
        for i = 1:(N_t + N_idle_t) 
            for j = 1:N_l 
                for k = 1:N_d
                    X_t2l_ij(i,j,k) <= X_t2d(i,k);
                    X_t2l_ij(i,j,k) <= X_d2l(k,j);
                    X_t2l_ij(i,j,k) >= X_t2d(i,k) + X_d2l(k,j) - 1;
                end
                X_t2l(i,j) == sum(X_t2l_ij(i,j,:));
            end
        end
        % end linearization of X_t2l = Xt2d*Xd2l
        
        % bandwidth constraint
        for i = 1: N_t + N_idle_t % for each source task
            if non_sensor_actuator_idle_t(i) == 1 % if it's not a sensor/actuator task
                for j = 1: N_t + N_idle_t % for each sink task
                    if i ~= j && G_t(i,j) == 1 % source i, sink j
                        % source-sink vectors
                        % (X_t2l(i,:))' means if t_i->l, l is a source
                        % (X_t2l(j,:))' means if t_j->l, l is a sink
                        % G_l*X_ptl(:,i,j) is a vector with the size of N_p_link
                        % each element indicates the usage of the p_link
                        G_l*X_ptl(:,i,j) == (X_t2l(i,:))' - (X_t2l(j,:))';
                        % bandwidth used for each p_link
                        Y(:,i,j) = R_r_b(i,j)*X_ptl(:,i,j);
                    end
                end
            end
        end
        % sum(Y,3) is the usage of p_link bandwidth from each source (sum over sink)
        % sum(sum(Y,3),2) is the total usage of p_link bandwidth by all sources (sum over sink, then source)
        sum(sum(Y,3),2) <= R_a_b
        % end bandwidth constraint
cvx_end
cvx_clear
X_t2d = uint8(full(X_t2d))
X_d2l = uint8(full(X_d2l))
X_t2l = uint8(full(X_t2l))
X_ptl = uint8(full(X_ptl));