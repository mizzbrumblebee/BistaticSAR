function [R0total,RB,dR] = doRangeMath(SAR,map,pulsenumber)
%UNTITLED9 Summary of this function goes here
% global P0
%   Detailed explanation goes here
%find distance from platform to center point
    %this value is constant from transmitter to center point
    RR0 = distanceformula(SAR.R(pulsenumber,1),SAR.P0(1,1),SAR.R(pulsenumber,2),SAR.P0(1,2));
%     SAR.L = distanceformula(SAR.R(r,1),SAR.T(1,1),SAR.R(r,2),SAR.T(1,2));
    R0total= SAR.RT0 + RR0; %disp(SAR.R0total);

    %approximate range from receiver to every point in the scene
%     [distancematrix,SAR] = rangeApproxSAR(map,SAR,r);
%     SAR.RRxmtx = distancematrix;
    RRxmtx = getRangeMatrix(map,SAR.R(pulsenumber,1),SAR.R(pulsenumber,2));
    RB = SAR.RTxmtx + RRxmtx; %matrix of ranges - for each platform position
    dR= RB - R0total;

end

