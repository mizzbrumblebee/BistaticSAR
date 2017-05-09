function [SAR] = getShiftedRxyMtx(SAR)
%UNTITLED4 Summary of this function goes here
% global numlevels rxxlength 
%   Detailed explanation goes here
    RXXMtx = repmat(SAR.RxxMtx,SAR.numlevels,1);
    RXY = fft(RXXMtx,SAR.rxxlength,2);
    RXYshift = fftshift(RXY,2); 
    RXYshift = RXYshift.*SAR.shiftmtx;
    RXYishift = ifftshift(RXYshift,2);
    SAR.RxyMtx = ifft(RXYishift,SAR.rxxlength,2); 
%     disp(SAR.RxyMtx);

end

