function [distance] = distanceformula3D(x1,x2,y1,y2,z1,z2)

dx=(x2-x1)^2;
dy=(y2-y1)^2;
dz=(z2-z1)^2;

distance=sqrt(dx+dy+dz);


end

