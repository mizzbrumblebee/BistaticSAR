function [ImageFinal,SAR,C,map] = getZoomedInImage(SAR,waveformstruct,map,gpuflag)

global c fc numpositions

if gpuflag ==1
    G = @(x) gpuArray(x);
else
    G = @(x) x;
end

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

    rangeprofile = SAR.datamatrix2(a1,:);

    phasecorrect = exp(k*rangematrix1);

    d = rangematrix1 > minrange;
    d2 = rangematrix1 < maxrange;
    Image = find(and(d,d2));

    i1 = interp1(SAR.rangearray,rangeprofile,rangematrix1(Image),'linear');
    p = phasecorrect(Image);
    ImageFinal(Image) = ImageFinal(Image) + i1.*p;
  
    elapsed = toc;
    disp(elapsed);
    disp(a1);

end

C = gather(G);

end

