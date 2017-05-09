%phase shift matrix
function [SAR] = getShiftMatrix(SAR,waveformstruct)

% global numlevels;
% global pl;

denominator = SAR.numlevels/2;
fftlength0 = 2*SAR.pl-1;
Fvar0 = (((0:fftlength0-1).*(1/fftlength0)) - .5);
Fvar = Fvar0*waveformstruct.SR;
num0 = floor(SAR.numlevels/2);

shifts0 = ((-1*num0:1:num0)/(2*denominator));
shifts = (shifts0/(waveformstruct.BW*10^6)).';
SAR.shiftmtx = exp(-1*1j*2*pi*shifts*Fvar);

end


























