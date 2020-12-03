cvx_begin quiet
    variable X_swHJ2Data(N_softwares_per_type(SW_Avionics_H)+N_softwares_per_type(SW_Avionics_J), N_softwares_per_type(SW_Data_acquisition)) binary
    % assume one source-multiple sinks
    sum(X_swHJ2Data,1) == 1; % every SW_Data_acquisition must be called by one SW_Avionics
    sum(X_swHJ2Data,2) >= 1; % every SW_Avionics must call at least one SW_Data_acquisition
cvx_end
X_swHJ2Data = full(X_swHJ2Data);

cvx_begin quiet
    variable X_swHJ2LRU(N_softwares_per_type(SW_Avionics_H)+N_softwares_per_type(SW_Avionics_J), N_LRUs) binary
    % assume one source-multiple sinks
    sum(X_swHJ2LRU,1) == 1; % every N_LRUs must be called by one SW_Avionics
    sum(X_swHJ2LRU,2) >= 1; % every SW_Avionics must call at least one N_LRUs
cvx_end
X_swHJ2LRU = full(X_swHJ2LRU);

X_alloc2stat_H = ones(N_softwares_per_type(SW_Allocator_H), N_softwares_per_type(SW_Status_check_H));
X_alloc2stat_J = ones(N_softwares_per_type(SW_Allocator_J), N_softwares_per_type(SW_Status_check_J));

% assuming the number of LRU and switch sw are zero
% G_sw = sparse([zeros(N_softwares_per_type(SW_Avionics_H)+N_softwares_per_type(SW_Avionics_J), N_softwares - N_softwares_per_type(SW_Data_acquisition)) X_swHJ2Data; 
%     zeros(N_softwares_per_type(SW_Allocator_H), N_softwares_per_type(SW_Avionics_H)+N_softwares_per_type(SW_Avionics_J)+N_softwares_per_type(SW_Allocator_H)+N_softwares_per_type(SW_Allocator_J)) ...
%     X_alloc2stat_H,  zeros(N_softwares_per_type(SW_Allocator_H), N_softwares_per_type(SW_Status_check_J)+N_softwares_per_type(SW_Data_acquisition));
%     zeros(N_softwares_per_type(SW_Allocator_J), N_softwares_per_type(SW_Avionics_H)+N_softwares_per_type(SW_Avionics_J)+N_softwares_per_type(SW_Allocator_H)+N_softwares_per_type(SW_Allocator_J)+N_softwares_per_type(SW_Status_check_H)) ...
%     X_alloc2stat_J zeros(N_softwares_per_type(SW_Allocator_J), N_softwares_per_type(SW_Data_acquisition))]);
% G_sw = sparse(blkdiag(X_swHJ2Data, X_alloc2stat_H, X_alloc2stat_J));

% source-sink matrix between softwares
G_sw = zeros(N_softwares + N_LRUs);
G_sw([SW_Avionics_H_ind SW_Avionics_J_ind], SW_Data_Acquisition_ind) = X_swHJ2Data;
G_sw([SW_Avionics_H_ind SW_Avionics_J_ind], end-N_LRUs+1:end) = X_swHJ2LRU;
G_sw(SW_Allocator_H_ind, SW_Status_Check_H_ind) = X_alloc2stat_H;
G_sw(SW_Allocator_J_ind, SW_Status_Check_J_ind) = X_alloc2stat_J;
G_sw = sparse(G_sw);
[G_sw_i, G_sw_j, ~] = find(G_sw);

% incident matrix between switches and ethernet cables 
G_es = zeros(N_links, N_switches);
G_es(1,1) = 1;
G_es(1,2) = -1;
G_es(2,1) = 1;
G_es(2,3) = -1;
G_es(3,1) = 1;
G_es(3,7) = -1;
G_es(4,2) = 1;
G_es(4,4) = -1;
G_es(5,2) = 1;
G_es(5,7) = -1;
G_es(6,3) = 1;
G_es(6,4) = -1;
G_es(7,3) = 1;
G_es(7,5) = -1;
G_es(8,3) = 1;
G_es(8,7) = -1;
G_es(9,4) = 1;
G_es(9,6) = -1;
G_es(10,4) = 1;
G_es(10,7) = -1;
G_es(11,5) = 1;
G_es(11,6) = -1;
G_es = G_es';