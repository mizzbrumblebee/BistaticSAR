function [distancematrix] = getRangeMatrix(map,xposition,yposition)

% taumatrix=zeros(length(xgrid),length(ygrid));%,length(velocity));
% distancematrix=zeros(size(taumatrix));
%calculate the associated time delay of each point on the mxn grid
%put these results in an equal sized nxn matrix
%where taup(5,5) returns the time delay at x=5 y=5
%have to shift values for X1 so that they will range between [0 gridsize]

% for i=1:length(xgrid)
%     for n=1:length(ygrid)
%         [X1] = [xgrid(i) ygrid(n) z];
%         distancetotal=distanceformula3D(xposition,X1(1,1),yposition,X1(1,2),0,X1(1,3));
% %         distanceXT=distanceformula(T(1,1),X1(1,1),T(1,2),X1(1,2));
% %         distancetotal=distanceXR+distanceXT;
% %         tau1=tau(distancetotal); %function tau
%         distancematrix(i,n)=distancetotal;
% %         taumatrix(i,n)=tau1; 
%     end
% end

z = 0;
z2 = z^2;

distancematrix = sqrt((map.xpositions-xposition).^2 + (map.ypositions - yposition).^2 + z2);

end

