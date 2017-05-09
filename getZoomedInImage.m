function [ImageFinal,SAR,C,map] = getZoomedInImage(SAR,waveformstruct,map,gpuflag)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

global c fc numpositions

if gpuflag ==1
    G = @(x) gpuArray(x);
else
    G = @(x) x;
end
% ImageFinal = 0;
% global numpositions fc Lp RBmin RBmax c 
% c = 3e8;
% SAR.numpositions = G(SAR.numpositions);
% SAR.AF = G(SAR.AF);
% SAR.RB = G(SAR.RB);
% waveformstruct.fc = G(waveformstruct.fc);
% SAR.minrange = G(SAR.minrange);
% SAR.maxrange = G(SAR.maxrange);
% SARLp = G(Lp);
SAR.rangearray = G(SAR.rangearray);
minrange = SAR.RBmin - (c*waveformstruct.dtau/2);
maxrange = SAR.RBmax - (c*waveformstruct.dtau/2);
% xfinal = map.xgrid(1,501);
%SIDE LOOKING CASE
map.ximageg = linspace(map.xgridi(1,77),map.xgridi(1,127),500); map.yimageg = linspace(map.ygridi(1,225),map.ygridi(1,275),500);

%THIS IS FOR THE CENTER CASE WHEN X AND Y INITIAL ARE 1000
% map.ximageg = linspace(map.xgridi(1,225),map.xgridi(1,275),500); map.yimageg = linspace(map.ygridi(1,225),map.ygridi(1,275),500);
map.ximage = repmat(map.ximageg.',1,length(map.yimageg));
map.yimage = repmat(map.yimageg,length(map.ximageg),1);

RBT = getRangeMatrixImage(map,SAR.T(1,1),SAR.T(1,2));
k = 1*1j*2*pi*fc/c;
for a1 = 1:numpositions
    RBR = getRangeMatrixImage(map,SAR.R(a1,1),SAR.R(a1,2));
    rangematrix1 = RBR + RBT;
    if a1 ==1
        ImageFinal = zeros(size(rangematrix1));
        ImageFinal = G(ImageFinal);
    end
%     rangeprofile = G(resample(SAR.AF(a1,:),10,1));
    rangeprofile = SAR.datamatrix2(a1,:);
%     rangematrix1 = RBI;
%     rangematrix1 = SAR.RB(:,:,a1) - SAR.R0all;
    %     rangevec = fouriervec*Wx/SAR.bplength;
    phasecorrect = exp(k*rangematrix1);
%     for a4 = 1:length(SAR.rangearray)
    %     rangeprofile = fftshift(ifft(matchedfilter(:,a1),SAR.bplength));
        
    d = rangematrix1 > minrange;
    d2 = rangematrix1 < maxrange;

    Image = find(and(d,d2));
%     Image = G(Image);
%         Image = find(rangematrix1 == SAR.RB(101,101,a1));
%         Image1(1:length(Image),a4,a1) = Image;
    i1 = interp1(SAR.rangearray,rangeprofile,rangematrix1(Image),'linear');

%         if i1 ~= 0
%            disp(a1); disp(a4); 
%         end
    p = phasecorrect(Image);
%         p = 1;

%         if length(i1) ~= length(p)
%             if length(i1) > length(p)
%                 i1 = i1(1:length(p));
%             else
%                 p = p(1:length(i1));
%             end
%         end

    ImageFinal(Image) = ImageFinal(Image) + i1.*p;
%         disp(size(ImageFinal(Image)));
    %     rImageFinal = ImageFinal + i1.*p;
%         disp(clock);
         
%     end      
    elapsed = toc;
    disp(elapsed);
    disp(a1);
%        disp(a1);
end

C = gather(G);

end

