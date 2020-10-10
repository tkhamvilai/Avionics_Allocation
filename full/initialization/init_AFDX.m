%% AFDX Topology
ss = [1 2 3 4 9 8 7 6 5 10 10 10 11 11 12 12 12 13 13 14 ...
    repelem([1 2 3 4 5 6 7 8 9], N_switches)];
tt = [2 3 4 9 8 7 6 5 1 11 12 16 13 16 13 14 16 15 16 15 ...
    repmat(N_locations_per_type(location_CRDC) + (1:N_switches), 1, N_locations_per_type(location_CRDC))];
AFDX_coordinate = [location_coordinate(1,1:N_locations_per_type(location_CRDC)) 256.6667 256.6667 570 570 1135 1135 413.3333;
    location_coordinate(2,1:N_locations_per_type(location_CRDC)) 16.6667 -16.6667 16.6667 -16.6667 16.6667 -16.6667 0];
AFDX_coordinate_scaled = AFDX_coordinate./max(AFDX_coordinate,[],2);
ww = zeros(1,length(ss));
for i = 1:length(ss)
   ww(i) = norm(AFDX_coordinate_scaled(:,ss(i)) - AFDX_coordinate_scaled(:,tt(i))); 
end
figure()
AFDX_topology = graph(ss,tt,ww);
NodeColor = [repmat([1 0 0], N_locations_per_type(location_CRDC), 1);
             repmat([0 0 1], N_switches, 1)];
plot(AFDX_topology,'XData',AFDX_coordinate_scaled(1,:),'YData',AFDX_coordinate_scaled(2,:),'NodeColor',NodeColor,'EdgeColor',[0 0 0],'EdgeLabel',AFDX_topology.Edges.Weight)

% do not know where CRDC will be placed beforehand, so use CRDC location instead
% CRDC location connects to the closet Switch
X_CRDC_l2s = zeros(N_locations_per_type(location_CRDC),N_switches);
for i = 1:N_locations_per_type(location_CRDC)
    [~,ind] = min(ww(1, 21 + (i-1)*N_switches: 27 + (i-1)*N_switches));
    X_CRDC_l2s(i,ind) = 1;
end

% Know exactly where CPIOM and LRU will be placed
% Connect CPIOM and LRU to Switch based on the reference AFDX topology
CPIOM_H2s_l = zeros(N_hardwares_per_type(HW_CPIOM_H),1);
CPIOM_H2s_l(1) = 3; % H31
CPIOM_H2s_l(2) = 4; % H32
CPIOM_H2s_l(3) = 5; % H33
CPIOM_H2s_l(4) = 6; % H34
CPIOM_H2s_l(5) = 5; % H41
CPIOM_H2s_l(6) = 6; % H42
CPIOM_H2s_l(7) = 3; % H43
CPIOM_H2s_l(8) = 4; % H44
CPIOM_H2s_l(9) = 3; % H61
CPIOM_H2s_l(10) = 4; % H62
CPIOM_H2s_l(11) = 5; % H63
CPIOM_H2s_l(12) = 6; % H64
X_CPIOM_H2s = zeros(N_hardwares_per_type(HW_CPIOM_H),N_switches);
for i = 1:N_hardwares_per_type(HW_CPIOM_H)
    X_CPIOM_H2s(i,CPIOM_H2s_l(i)) = 1;
end

CPIOM_J2s_l = zeros(N_hardwares_per_type(HW_CPIOM_J),1);
CPIOM_J2s_l(1) = 3; % J11
CPIOM_J2s_l(2) = 4; % J12
CPIOM_J2s_l(3) = 1; % J21
CPIOM_J2s_l(4) = 2; % J22
CPIOM_J2s_l(5) = 3; % J23
CPIOM_J2s_l(6) = 4; % J24
CPIOM_J2s_l(7) = 5; % J51
CPIOM_J2s_l(8) = 6; % J52
CPIOM_J2s_l(9) = 1; % J71
CPIOM_J2s_l(10) = 2; % J72
X_CPIOM_J2s = zeros(N_hardwares_per_type(HW_CPIOM_J),N_switches);
for i = 1:N_hardwares_per_type(HW_CPIOM_J)
    X_CPIOM_J2s(i,CPIOM_J2s_l(i)) = 1;
end

LRU2s_l = zeros(N_LRUs,1);
LRU2s_l(1:11) = 1;
LRU2s_l(12:22) = 2;
LRU2s_l(23:29) = 3;
LRU2s_l(30:36) = 4;
LRU2s_l(37:40) = 5;
LRU2s_l(41:44) = 6;
LRU2s_l(45:55) = 7;
X_LRU2s = zeros(N_LRUs,N_switches);
for i = 1:N_LRUs
    X_LRU2s(i,LRU2s_l(i)) = 1;
end