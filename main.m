clc; clear; close all

% cvx_setup cvx\cvx_license.dat
% cvx_solver Gurobi
% cvx_save_prefs

%% Input Parameters
N_sw = 3; % the number of unique software
N_hw = 4; % the number of unique hardware
assert(N_sw > 0);
assert(N_hw > 0);

sw_redundancy = [3 3 2]; % the number of copies for each unqiue software
assert(length(sw_redundancy) == N_sw);

hw_redundancy = [3 3 2 2]; % the number of copies for each unqiue hardware
assert(length(hw_redundancy) == N_hw);

% This A1 matrix determines which unqiue software can be run on which unqiue hardware
A1 = [1 1 1 1;
      1 1 1 0;
      1 1 0 0];
assert(isequal(size(A1) , [N_sw N_hw]));

%% Deriving Model Parameters
N_sw_tot = sum(sw_redundancy); % total number of software
N_hw_tot = sum(hw_redundancy); % total number of hardware

% This B1 matrix defines which software can be run on which unique hardware
% This includes software redundancy
B1 = zeros(N_sw_tot, N_hw);
ind = 1;
for i = 1:N_sw
    for j = 1:sw_redundancy(i)
        for k = 1:N_hw
            B1(ind,k) = A1(i,k);
        end
        ind = ind + 1;
    end
end

% This B2 matrix defines which hardware has which type
% Note hardware redundancy implies the same type of hardware
B2 = zeros(N_hw_tot, N_hw);
ind = 1;
for i = 1:N_hw
    for j = 1:hw_redundancy(i)
        B2(ind,i) = 1;
        ind = ind + 1;
    end
end

% This B3 matrix defines which software can be run on which hardware
% This include redundancies on both software and hardware
B3 = B1*B2';

% hardware resources are memory, I/O, and CPU
% memory is kind of plenty (may not be necessary to implement)
% I/O is less relevant if using Ethernet
% CPU usage should be handled by a scheduling constraint

% TODO: implement scheduling constraints
% TODO: implement topology, bandwidth, and communication constraints
% TODO: implement security constraints (out one odd on sw, then look at which hw executing that sw (using previous allocation result), then isolate that hw, already done in a separate file, need to put it here too.)
% TODO: implement fault constraints (kind of the same as security, but measure directly from hw not sw, then immediately isolate that hw, doesn't need a result from previous allocation)

% software priority coefficient vector
alpha = ones(N_sw_tot,1);

%% Problem Formulation
cvx_begin
    % r(i) = 1 means software i is running
    variable r(N_sw_tot, 1) binary

    % X_sw2hw(i,j) = 1 means software i is allocated to hardware j
    variable X_sw2hw(N_sw_tot, N_hw_tot) binary

    maximize sum(r)
    subject to
        % allocation constraint
        % running software must be allocated to a hardware
        sum(X_sw2hw,2) == r; % this is a vector equation

        % type constraint
        % software can be run on its compatible hardware
        X_sw2hw <= B3;

        % segregation constraint
        % redundant software cannot be run on the same hardware
        start_ind = 1;
        for i = 1:N_sw
            end_ind = start_ind + sw_redundancy(i) - 1;
            for j = 1:N_hw_tot
                sum(X_sw2hw(start_ind:end_ind,j)) <= 1;
            end
            start_ind = end_ind + 1;
        end
        
        % assuming each hardware can hold at most two software (for now)
        % need to be change to a scheduling constraint
        sum(X_sw2hw,1) <= 2; % this is a vector equation
cvx_end
cvx_clear
