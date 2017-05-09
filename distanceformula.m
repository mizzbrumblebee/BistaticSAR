function [distance] = distanceformula(x1,x2,y1,y2)

dx=(x2-x1)^2;
dy=(y2-y1)^2;

distance=sqrt(dx+dy);


end

