clc; clear; close all

signals = [10.1; 10.05; 9.5; 10.0]; % signals/outputs from software 
%  redundant software in this case where the 3th one is faulty

N_sw_tot = length(signals);
N_hw_tot = 6; % the assumed number of hardware devices

% this could be the allocation result from the previous iteration
X_sw2hw_prev = [1 0 0 0 0 0;
                0 1 0 0 0 0;
                0 0 0 1 0 0;
                0 0 0 0 1 0];
columnSums = sum(X_sw2hw_prev,1);
nonZeroColumns = find(columnSums ~= 0); % indices of hw that were running sw
assert(size(X_sw2hw_prev,1) == N_sw_tot);
assert(size(X_sw2hw_prev,2) == N_hw_tot);

epsilon = 0.1; % each signal can be different by this much

cvx_begin
    variable x(N_sw_tot, N_sw_tot) binary 
    variable healthy_software(N_sw_tot, 1) integer
    variable X_sw2hw(N_sw_tot, N_hw_tot) binary
    maximize sum(sum(x))
    subject to
        % for each redudant software
        for i = 1:N_sw_tot
            for j = 1:N_sw_tot
                if i ~= j
                     signals(i)*x(i,j) - signals(j)*x(j,i) <= epsilon;
                    -signals(i)*x(i,j) + signals(j)*x(j,i) <= epsilon;
                else
                    x(i,j) == 0; % no need to compare the signal to itself
                end
            end
        end
        healthy_software == sum(x,2); % threat detection here

        % isolation here, exclude hw that weren't running sw
        sum(X_sw2hw(:,nonZeroColumns),1) <= healthy_software'*X_sw2hw_prev(:,nonZeroColumns);

        sum(X_sw2hw,2) == 1; % each software must be allocated on only one hardware
        sum(X_sw2hw,1) <= 1; % each hardware can run almost one software (not necessary)
cvx_end
cvx_clear