%% Aircraft Topology
s = [10  1 11 12  2 13  3 14  4 15  9 19  8 18  7 17  6 16  5  2 20 22 25 23 21  7 26 28 31 29 27];
t = [ 1 11 12  2 13  3 14  4 15  9 19  8 18  7 17  6 16  5 10 20 22 24 23 21  3 26 28 30 29 27  8];
N_vertices = N_IO_location + N_locations_per_type(location_CRDC);
N_edges = length(s);
location_coordinate = [100 570 930 1340 100 335 570 930 1340 0 256.6667 413.3333 750 1135 1640 217.5 452.5 750 1135 640 920 760 920 810 970 640 920 760 920 810 970;
    50 50 50 50 -50 -50 -50 -50 -50 0 50 50 50 50 0 -50 -50 -50 -50 120 120 280 280 390 390 -120 -120 -280 -280 -390 -390];
location_coordinate = location_coordinate./max(location_coordinate,[],2);
w = zeros(1,N_edges);
for i = 1:N_edges
   w(i) = norm(location_coordinate(:,s(i)) - location_coordinate(:,t(i))); 
end
location_topology = graph(s,t,w);
NodeColor = [repmat([1 0 0], N_locations_per_type(location_CRDC), 1);
             repmat([0 0 1], N_IO_location, 1)];
plot(location_topology,'XData',location_coordinate(1,:),'YData',location_coordinate(2,:),'NodeColor',NodeColor,'EdgeColor',[0 0 0],'EdgeLabel',location_topology.Edges.Weight)
% plot(location_topology,'XData',location_coordinate(1,:),'YData',location_coordinate(2,:),'EdgeColor',[0 0 0])