clear all;  clc; tic; %close all;
%257 m/s
% format shortg
%profile on;

%all distances are given in units of km
% global c;
c=3e8; 
gpuflag = 0;
% global gpuflag;
% THIS SCRIPT IS PRIMARILY FOR INITIALIZATION. 
% global c;
% global fc;
% global numpositions;
% global SAR.numlevels;
% global Lp;
% global minsamples;
% global pl;
% global RBmin;
% global RBmax;
% global rxxlength; 
% global P0;
% global SAR.center_sample;
% 
waveformstruct.samewaveform = 'no';
tic;
c = 3e8; waveformstruct.fc = 728e6;
lambda=c/waveformstruct.fc;
SAR.numpositions = 1;
SAR.numlevels = 35;


time = .001; %time between collections in seconds
%platform speed
platformv=100; %approximate target speed is 70 mph, which is .031 km/s 
NDLRB_values = [6 15 25 50 75 100]; %according to LTE standard
% Configure the set of NDLRB values to describe the carriers to be
% aggregated
waveformstruct.NDLRB = [25 25 25 25 25 25];
Elim=.01;
waveformstruct = generateLTEWaveform(waveformstruct);
waveformstruct.fraction = .500;
waveformstruct.E = zeros(1,SAR.numpositions);
waveformstruct.Ts=1/waveformstruct.SR;
waveformstruct.dtau = 1/(waveformstruct.BW*1e6);
dv = platformv*time;



%sets up moving platform


%FOR ORIGINAL CASE X AND Y INITIAL ARE BOTH 1000
map.yinitial = 1000;
map.xinitial = 0; %make 0 for side looking
map.gspacing = .25*c/(2*waveformstruct.BW*10^6);
map.elements = 2000;
% map.gridsize = map.gspacing*map.elements + map.initial;
map.xgrid=(0:map.gspacing:map.gspacing*map.elements) + map.xinitial; %create 1xn arrays for x and y coordinates
map.ygrid=(0:map.gspacing:map.gspacing*map.elements) + map.yinitial;
map.xgridi=(0:4*map.gspacing:map.gspacing*map.elements) + map.xinitial; %create 1xn arrays for x and y coordinates
map.ygridi=(0:4*map.gspacing:map.gspacing*map.elements) + map.yinitial;
map.xpositions = repmat(map.xgrid.',1,length(map.ygrid));
map.ypositions = repmat(map.ygrid,length(map.xgrid),1);




SAR.R=zeros(SAR.numpositions,2); %receiver coordinates--RIL in the center
SAR.R(1,1) = 510;
SAR.R(:,1) = arrayfun(@(r) SAR.R(1,1) + (r-1)*dv,1:SAR.numpositions);
SAR.T=[0 0];
SAR0.R = [SAR.R(1,1) 0]; SAR0.T = [0 0];
[SAR0.RTxmtx] = getRangeMatrix(map,SAR0.T(1,1),SAR0.T(1,2));
[SAR0.RRxmtx] = getRangeMatrix(map,SAR0.R(1,1),SAR0.R(1,2));
SAR0.distance = SAR0.RTxmtx + SAR0.RRxmtx;
SAR.RBmax = max(SAR0.distance(:));
taup = SAR0.distance/c;
taumax=max(taup(:)); 
taumin = min(taup(:));
SAR.RBmin = min(SAR0.distance(:));%use this for maximum time delay


SAR.Lp = floor(taumax.*1/waveformstruct.dtau);
SAR.minsamples = floor(taumin.*1/waveformstruct.dtau);
SAR.pl = SAR.Lp - SAR.minsamples;


%initialization for reverse backprojection
SAR.P0 = [(map.xgrid(1)+map.xgrid(end))/2 (map.ygrid(1)+map.ygrid(end))/2];

%transmitter range doesn't change - calculate before loop
SAR.RT0 = distanceformula(SAR.T(1,1),SAR.P0(1,1),SAR.T(1,2),SAR.P0(1,2));
% SAR.Rp = map.ypositions - SAR.R(1,2);
[SAR.RTxmtx] = getRangeMatrix(map,SAR.T(1,1),SAR.T(1,2));

%check these variables to see where they pass through
SAR.RxxMtx = zeros(SAR.numlevels,2*SAR.pl-1,SAR.numpositions);
SAR.rxxlength = 2*SAR.pl - 1;

SAR.center_sample = round(SAR.rxxlength/2);
SAR.datamatrix = zeros(SAR.numpositions,SAR.pl);
SAR.clutter_mtx = getClutterMap(map);
SAR.shiftmtx = zeros(SAR.numlevels,1);
SAR = getShiftMatrix(SAR,waveformstruct); 




%reverse backprojection algorithm
[SAR,waveformstruct] = getDataMatrix(waveformstruct,SAR,map);
elapsedtime = toc;
format shortg;
disp(elapsedtime);




gpuflag = 0;
rangearray0 = linspace(SAR.RBmin,SAR.RBmax,SAR.pl);
SAR.rangearray = linspace(SAR.RBmin,SAR.RBmax,10*SAR.pl);
fprintf('creating Image1');
% ImageFinal = 0;
[ImageFinal,SAR,C,map] = getImage(SAR,waveformstruct,map,gpuflag);
fprintf('creating image2');
% ImageFinal2 = 0;
[ImageFinal2,SAR,C,map] = getZoomedInImage(SAR,waveformstruct,map,gpuflag);


pulseDoppler = fftshift(fft(SAR.datamatrix,[],1),1);
N = SAR.numpositions;
dopplerarray = linspace(-N/2,N/2,N);

figure
imagesc(rangearray0,1:SAR.numpositions,abs(SAR.datamatrix))
title('Generated Data for 1 point scatter(s)');
xlabel('Range (m)');
ylabel('Pulse Number');

% figure
% imagesc(rangearray0,1:SAR.numpositions,abs(K))
% title('Generated Data for 1 point scatter(s)');
% xlabel('Range (m)');
% ylabel('Pulse Number');

% figure
% imagesc(rangearray0,dopplerarray,abs(pulseDoppler))

figure
imagesc(map.xgridi,map.ygridi,abs(ImageFinal.'))
set(gca, 'YDir', 'normal');
title('Reconstructed image of 1 point scatterer(s)');
xlabel('X-coordinate (m)');
ylabel('Y-coordinate (m)');

figure
imagesc(map.ximageg,map.yimageg,abs(ImageFinal2.'))
set(gca, 'YDir', 'normal');
title('Reconstructed image of 1 point scatterer(s)');
xlabel('X-coordinate (m)');
ylabel('Y-coordinate (m)');
colormap(gray(256));

for n = 261:280
    figure
    plot(map.ximageg,abs(ImageFinal2(:,n)))
    title('Doppler Sidelobes');
    xlabel('x-coordinate (m)');
    ylabel('Image intensity');
end
t = datestr(now,30);
t3 =strcat(t,'.mat');
K = SAR.datamatrix;
% save(t3,'K');
t2 = strcat(t,'Image.mat');
t4 = strcat(t,'Image2.mat');
% save(t2,'ImageFinal');
% save(t4,'ImageFinal2');