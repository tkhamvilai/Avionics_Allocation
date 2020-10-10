N_var = N_softwares_symm * N_hardwares_symm + ... % X_sw2hw(i,j) = 1 means SW i is allocated to HW j
        N_hardwares_symm * N_locations_symm + ... % X_hw2l(i,j) = 1 means HW i is allocated to location j
        N_softwares_symm * N_locations_symm + ... % X_sw2l(i,j) = 1 means SW i is allocated to location j
        N_softwares_symm * N_locations_symm * N_hardwares_symm + ... % X_sw2l_aux
        0;
    
N_constr = N_softwares_symm + ... % every SW must be allocated to a HW
           N_hardwares_symm + ... % every HW must be allocated to at most one location
           3*N_hardwares_symm + ... % SW->HW resource constraints
           1*N_locations_symm + ... % HW->Location resource constraints
           N_softwares_symm*N_locations_symm + ... % X_sw2l = Xsw2hw*Xhw2l
           3*N_softwares_symm*N_locations_symm*N_hardwares_symm + ... % X_sw2l_aux
           0;

obj = ones(1,N_var);
A = sparse(N_constr, N_var);
b = zeros(N_constr, 1);
sense = [];

% every SW must be allocated to a HW
var_ind = 1;
const_ind = 1;
for i = 1:N_softwares_symm
    for j = 1:N_hardwares_symm
        A((i-1) + const_ind, (i-1) + var_ind + (j-1)*N_softwares_symm) = 1;
    end
    b((i-1) + const_ind, 1) = 1;
end
sense = [sense char('='*ones(1,N_softwares_symm))];

% every HW must be allocated to at most one location
var_ind = 1 + N_softwares_symm * N_hardwares_symm;
const_ind = 1 + N_softwares_symm;
for i = 1:N_hardwares_symm
    for j = 1:N_locations_symm
        A((i-1) + const_ind, (i-1) + var_ind + (j-1)*N_hardwares_symm) = 1;
    end
    b((i-1) + const_ind, 1) = 1;
end
sense = [sense char('='*ones(1,N_hardwares_symm))];

% SW->HW resource constraint
var_ind = 1;
const_ind = 1 + N_softwares_symm + N_hardwares_symm;
for i = 1:N_hardwares_symm
    for j = 1:N_softwares_symm
        A((i-1) + const_ind, (i-1)*N_softwares_symm + var_ind + (j-1)) = softwares{j,1}.required_memory;
        A((i-1) + const_ind + N_hardwares_symm, (i-1)*N_softwares_symm + var_ind + (j-1)) = length(softwares{j,1}.required_IO);
        A((i-1) + const_ind + 2*N_hardwares_symm, (i-1)*N_softwares_symm + var_ind + (j-1)) = softwares{j,1}.required_bandwidth;
    end
    b((i-1) + const_ind, 1) = hardwares{i,1}.available_memory;
    b((i-1) + const_ind + N_hardwares_symm, 1) = hardwares{i,1}.available_IO;
    b((i-1) + const_ind + 2*N_hardwares_symm, 1) = hardwares{i,1}.available_bandwidth;
end
sense = [sense char('<'*ones(1,3*N_hardwares_symm))];

% HW->Location resource constraint
var_ind = 1 + N_softwares_symm * N_hardwares_symm;
const_ind = 1 + N_softwares_symm + 4*N_hardwares_symm;
for i = 1:N_locations_symm
    for j = 1:N_hardwares_symm
        A((i-1) + const_ind, (i-1)*N_hardwares_symm + var_ind + (j-1)) = hardwares{j,1}.required_area;
    end
    b((i-1) + const_ind, 1) = locations{i,1}.available_area;
end
sense = [sense char('<'*ones(1,1*N_locations_symm))];

% linearization of X_sw2l = Xsw2hw*Xhw2l
var_ind = 1 + N_softwares_symm * N_hardwares_symm + N_hardwares_symm * N_locations_symm;
var_ind_aux = var_ind + N_softwares_symm * N_locations_symm;
const_ind = 1 + N_softwares_symm + 4*N_hardwares_symm + 1*N_locations_symm;
const_ind_aux = const_ind + N_softwares_symm*N_locations_symm;
for i = 1:N_softwares_symm
    for j = 1:N_locations_symm 
        for k = 1:N_hardwares_symm
            A(const_ind_aux + (i-1)*N_softwares_symm*N_locations_symm + (j-1)*N_locations_symm + (k-1), ...
                var_ind_aux + (i-1)*N_softwares_symm*N_locations_symm + (j-1)*N_locations_symm + (k-1)) = 1;
            
            A(const_ind_aux + (i-1)*N_softwares_symm*N_locations_symm + (j-1)*N_locations_symm + (k-1), ...
                1 + (i-1) + (k-1)*N_softwares_symm) = -1;
            
            b(const_ind_aux + (i-1)*N_softwares_symm*N_locations_symm + (j-1)*N_locations_symm + (k-1), 1) = 0;
            sense = [sense '<'];
            
            A(const_ind_aux + N_softwares_symm*N_locations_symm*N_hardwares_symm + ...
                (i-1)*N_softwares_symm*N_locations_symm + (j-1)*N_locations_symm + (k-1), ...
                var_ind_aux + (i-1)*N_softwares_symm*N_locations_symm + (j-1)*N_locations_symm + (k-1)) = 1;
            
            A(const_ind_aux + N_softwares_symm*N_locations_symm*N_hardwares_symm + ...
                (i-1)*N_softwares_symm*N_locations_symm + (j-1)*N_locations_symm + (k-1), ...
                1 + N_softwares_symm*N_hardwares_symm + (k-1) + (j-1)*N_hardwares_symm) = -1;
            
            b(const_ind_aux + N_softwares_symm*N_locations_symm*N_hardwares_symm + ...
                (i-1)*N_softwares_symm*N_locations_symm + (j-1)*N_locations_symm + (k-1), 1) = 0;
            sense = [sense '<'];
            
            A(const_ind_aux + 2*N_softwares_symm*N_locations_symm*N_hardwares_symm + ...
                (i-1)*N_softwares_symm*N_locations_symm + (j-1)*N_locations_symm + (k-1), ...
                var_ind_aux + (i-1)*N_softwares_symm*N_locations_symm + (j-1)*N_locations_symm + (k-1)) = -1;
            
            A(const_ind_aux + 2*N_softwares_symm*N_locations_symm*N_hardwares_symm + ...
                (i-1)*N_softwares_symm*N_locations_symm + (j-1)*N_locations_symm + (k-1), ...
                1 + (i-1) + (k-1)*N_softwares_symm) = 1;
            
            A(const_ind_aux + 2*N_softwares_symm*N_locations_symm*N_hardwares_symm + ...
                (i-1)*N_softwares_symm*N_locations_symm + (j-1)*N_locations_symm + (k-1), ...
                1 + N_softwares_symm*N_hardwares_symm + (k-1) + (j-1)*N_hardwares_symm) = 1;  
            
            b(const_ind_aux + 2*N_softwares_symm*N_locations_symm*N_hardwares_symm + ...
                (i-1)*N_softwares_symm*N_locations_symm + (j-1)*N_locations_symm + (k-1), 1) = 1;
            sense = [sense '<'];
            
%             X_sw2l_aux(i,j,k) <= X_sw2hw(i,k);
%             X_sw2l_aux(i,j,k) <= X_hw2l(k,j);
%             X_sw2l_aux(i,j,k) >= X_sw2hw(i,k) + X_hw2l(k,j) - 1;

            A(const_ind + (i-1)*N_softwares_symm + (j-1), ...
                var_ind_aux + (i-1)*N_softwares_symm*N_locations_symm + (j-1)*N_locations_symm + (k-1)) = -1;
        end
        A(const_ind + (i-1)*N_softwares_symm + (j-1), ...
            var_ind + (i-1)*N_softwares_symm + (j-1)) = 1;
        b(const_ind + (i-1)*N_softwares_symm + (j-1), 1) = 0;
        sense = [sense '='];
%         X_sw2l(i,j) == sum(X_sw2l_aux(i,j,:));
    end
end

model.A = sparse(A);
model.obj = obj;
model.modelsense = 'min';
model.rhs = b;
model.vtype = 'B';
model.sense = sense;

params.outputflag = 1;
params.Threads = 8;

gurobi_result = gurobi(model, params);
disp(gurobi_result);

X_sw2hw = reshape(gurobi_result.x(1:N_softwares_symm*N_hardwares_symm),[N_softwares_symm,N_hardwares_symm]);
X_hw2l = reshape(gurobi_result.x(1+N_softwares_symm*N_hardwares_symm:N_softwares_symm*N_hardwares_symm+N_hardwares_symm * N_locations_symm),[N_hardwares_symm,N_locations_symm]);