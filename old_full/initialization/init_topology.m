%% Aircraft Topology
s = [ 1  1  2  2  3  3  4  4  4  5  5  5  6  6  7  7  8  8  9  9 10 10 10 11 11 11 12 12 20 21 22 23 31 32 33 34];
t = [13 14 14 15 15 16 16 17 20 17 18 21 18 19 13 26 26 27 27 28 28 29 31 29 30 32 30 19 22 23 24 25 33 34 35 36];
N_vertices = N_install_locations + N_IO_location;
N_edges = length(s);
location_coordinate = [100 200 390 570 930 1340 100 200 390 570 930 1340 0 150 300 480 750 1140 1640 640 920 760 920 810 970 150 300 480 750 1140 640 920 760 920 810 970;
    50 50 50 50 50 50 -50 -50 -50 -50 -50 -50 0 50 50 50 50 50 0 120 120 280 280 390 390 -50 -50 -50 -50 -50 -120 -120 -280 -280 -390 -390];
location_coordinate = location_coordinate./max(location_coordinate,[],2);
w = zeros(1,N_edges);
for i = 1:N_edges
   w(i) = norm(location_coordinate(:,s(i)) - location_coordinate(:,t(i))); 
end
location_topology = graph(s,t,w);
NodeColor = [repmat([1 0 0], N_install_locations, 1);
             repmat([0 0 1], N_IO_location, 1)];
plot(location_topology,'XData',location_coordinate(1,:),'YData',location_coordinate(2,:),'NodeColor',NodeColor,'EdgeColor',[0 0 0],'EdgeLabel',location_topology.Edges.Weight)