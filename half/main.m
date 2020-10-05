clc; clear; close all

% cvx_solver Gurobi_2
% cvx_save_prefs

addpath components initialization helpers

%% Initialization
init_main;
disp('Initialization Successful')

%% Problem Formulation
% addpath '/opt/gurobi903/linux64/matlab'
% gurobi_prob_model_solve;
disp('Start formulating problem...')
cvx_prob_model_solve;