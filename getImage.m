function [ImageFinal,SAR,C,map] = getImage(SAR,waveformstruct,map,gpuflag)

global c fc numpositions

if gpuflag ==1
    G = @(x) gpuArray(x);
else
    G = @(x) x;
end

SAR.rangearray = G(SAR.rangearray);
SAR.datamatrix2 = G(SAR.datamatrix2);

minrange = SAR.RBmin - (c*waveformstruct.dtau/2);
maxrange = SAR.RBmax - (c*waveformstruct.dtau/2);
map.ximage = repmat(map.xgridi.',1,length(map.ygridi));
map.yimage = repmat(map.ygridi,length(map.xgridi),1);

RBT1 = getRangeMatrixImage(map,SAR.T(1,1),SAR.T(1,2));

k = 1*1j*2*pi*fc/c;
for a1 = 1:numpositions
%     SAR.RBR = rangeMatrixSARImage(map,SAR.R(a1,1),SAR.R(a1,2));
%     SAR.RBI = SAR.RBR + SAR.RBT;
    RBR1 = getRangeMatrixImage(map,SAR.R(a1,1),SAR.R(a1,2));
    rangematrix1 = RBR1 + RBT1;
    if a1 ==1
        ImageFinal = zeros(size(map.ximage));
        ImageFinal = G(ImageFinal);
    end
%     rangeprofile = G(resample(SAR.AF(a1,:),10,1));
    rangeprofile = SAR.datamatrix2(a1,:);
%     rangematrix1 = SAR.RBI - SAR.R0all;
%     rangematrix1 = SAR.RBI1;

    phasecorrect = exp(k*rangematrix1);
    
    d = rangematrix1 > minrange;
    d2 = rangematrix1 < maxrange;
    Image = find(and(d,d2));

    i1 = interp1(SAR.rangearray,rangeprofile,rangematrix1(Image),'linear');     
    p = phasecorrect(Image);
    ImageFinal(Image) = ImageFinal(Image) + i1.*p;
%         
    disp(a1);
    elapsedtime = toc;
    format shortg;
    disp(elapsedtime);
end
C = gather(G);
end

