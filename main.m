clc; clear; close all

% cvx_setup cvx\cvx_license.dat
% cvx_solver Gurobi
% cvx_save_prefs

%% Input Parameters
N_d = 4; % the number of devices
N_t = 6; % the number of tasks