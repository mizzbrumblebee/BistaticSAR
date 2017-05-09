%generate clutter map
function [clutter_mtx] = getClutterMap(map)
clutter_mtx = zeros(length(map.xgrid),length(map.ygrid));

% clutter_mtx(:,1:(map.elements/2)) = 0;
% clutter_mtx(1:(map.elements/2),(map.elements/2):map.elements) = 1/3;
% clutter_mtx((map.elements/2):map.elements,(map.elements/2):(3*map.elements/4)) = 1/2;
% clutter_mtx((map.elements/2):(3*map.elements/4),3*(map.elements/4):map.elements) = 3/4;
% clutter_mtx((3*map.elements/4):map.elements,(3*map.elements/4):map.elements) = 1;
% target.X = zeros(target.numtargets,2);
% target.X(1,:)=[900 900]; 
% target.X(2,:) = [800 200];
% % target.X(3,:)=[850 150]; 
% % target.X(4,:) = [750 250];
% % target.X(5,:) = [700 300];
% % 
% target.xindex=floor((target.X(:,1)/map.gridsize)*map.elements+1);
% target.yindex=floor((target.X(:,2)/map.gridsize)*map.elements+1);
% % 
% for n = 1:2
%     
%     clutter_mtx(target.xindex(n,1),target.yindex(n,1)) = 5;
% end

clutter_mtx(405,round(length(map.ygrid)/2)) = 5;
% clutter_mtx(round(length(map.ygrid)/2),round(length(map.ygrid)/2)) = 5;
% clutter_mtx(1,1) = 5;
% clutter_mtx(300,300) = 5;
% clutter_mtx(400,400) = 5;
% clutter_mtx(500,500) = 5;
% clutter_mtx(200,200) = 5;
% clutter_mtx(100,100) = 5;
% clutter_mtx(2001,2001) = 5;
% clutter_mtx(450,450) = 5;
% clutter_mtx(50:100,50) = 5;
% clutter_mtx(50:100,100) = 5;
% clutter_mtx(50,50:100) = 5;
% clutter_mtx(100,50:100) = 5;
% clutter_mtx(75:125,75) = 5;
% clutter_mtx(75:125,125) = 5;
% clutter_mtx(125,75:125) = 5;
% for n = 3:4
%     
%     clutter_mtx(target.xindex(n,1),target.yindex(n,1)) = 5;
% end
% clutter_mtx = sqrt(clutter_mtx/2)*(rand(size(clutter_mtx))+1j*rand(size(clutter_mtx)));

end