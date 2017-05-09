function [ImageFinal,SAR,C,map] = getImage(SAR,waveformstruct,map,gpuflag)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if gpuflag ==1
    G = @(x) gpuArray(x);
else
    G = @(x) x;
end
% global numpositions fc Lp RBmin RBmax
c = 3e8;
SAR.numpositions = G(SAR.numpositions);
% SAR.AF = G(SAR.AF);
% SAR.RB = G(SAR.RB);
waveformstruct.fc = G(waveformstruct.fc);
% SAR.minrange = G(SAR.minrange);
% SAR.maxrange = G(SAR.maxrange);
% SAR.Lp = G(SAR.Lp);
SAR.rangearray = G(SAR.rangearray);

% xfinal = map.xgrid(1,501);
% map.ximageg = map.xgrid(1,1):2:map.xgrid(1,100); map.yimageg = map.ygrid(1,400):2:map.ygrid(1,501);
% map.ximage = repmat(map.ximageg.',1,length(map.yimageg));
% map.yimage = repmat(map.yimageg,length(map.ximageg),1);
% 
% SAR.RBT = rangeMatrixSARImage(map,SAR.T(1,1),SAR.T(1,2));
minrange = SAR.RBmin - (c*waveformstruct.dtau/2);
maxrange = SAR.RBmax - (c*waveformstruct.dtau/2);
map.ximage = repmat(map.xgridi.',1,length(map.ygridi));
map.yimage = repmat(map.ygridi,length(map.xgridi),1);

RBT1 = getRangeMatrixImage(map,SAR.T(1,1),SAR.T(1,2));

k = 1*1j*2*pi*waveformstruct.fc/c;
for a1 = 1:SAR.numpositions
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
%     if a1 ==1
%         SAR.rangematrix1 = rangematrix1;
%     end
        
    %     rangevec = fouriervec*Wx/SAR.bplength;
    phasecorrect = exp(k*rangematrix1);
% for a4 = 1:length(SAR.rangearray)
%     rangeprofile = fftshift(ifft(matchedfilter(:,a1),SAR.bplength));

    d = rangematrix1 > minrange;
    d2 = rangematrix1 < maxrange;

    Image = find(and(d,d2));
%     Image = G(Image);
%         B = any(Image(:));
%         if B ==1
%         Image = find(rangematrix1 == SAR.RB(101,101,a1));
%         Image1(1:length(Image),a4,a1) = Image;
    i1 = interp1(SAR.rangearray,rangeprofile,rangematrix1(Image),'linear');

%         if a4 == 30
%            figure
%            imagesc(rangematrix1(Image))
%         end
% %         if any(i1)
%            disp(a4); 
%         end
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
%         end
%         disp(size(ImageFinal(Image)));
%     rImageFinal = ImageFinal + i1.*p;
%         disp(clock);

% end      
    disp(a1);
    elapsedtime = toc;
    format shortg;
    disp(elapsedtime);
end

% for a1 = 1:SAR.numpositions
% %     SAR.RBR = rangeMatrixSARImage(map,SAR.R(a1,1),SAR.R(a1,2));
% %     SAR.RBI = SAR.RBR + SAR.RBT;
%     if a1 ==1
%         ImageFinal2 = zeros(size(SAR.RB(:,:,1)));
%         ImageFinal2 = G(ImageFinal);
%     end
%     rangeprofile = G(resample(SAR.AF(a1,:),10,1));
%     rangematrix2 = SAR.RB(:,:,a1) - SAR.R0all;
% %     rangematrix1 = SAR.RB(:,:,a1) - SAR.R0all;
%     %     rangevec = fouriervec*Wx/SAR.bplength;
%     phasecorrect2 = exp(k*rangematrix2);
%     for a4 = 1:SAR.rangearray
%     %     rangeprofile = fftshift(ifft(matchedfilter(:,a1),SAR.bplength));
%         
%         d = rangematrix2 > SAR.minrange(a4);
%         d2 = rangematrix2 < SAR.maxrange(a4);
% 
%         Image2 = find(and(d,d2));
%         Image2 = G(Image2);
% %         Image = find(rangematrix1 == SAR.RB(101,101,a1));
% %         Image1(1:length(Image),a4,a1) = Image;
%         i2 = interp1(SAR.rangearray,rangeprofile,rangematrix2(Image2),'linear');
%         
% %         if i1 ~= 0
% %            disp(a1); disp(a4); 
% %         end
%         p2 = phasecorrect2(Image2);
% %         p = 1;
% 
% %         if length(i1) ~= length(p)
% %             if length(i1) > length(p)
% %                 i1 = i1(1:length(p));
% %             else
% %                 p = p(1:length(i1));
% %             end
% %         end
% 
%         ImageFinal2(Image2) = ImageFinal2(Image2) + i2.*p2;
% %         disp(size(ImageFinal(Image)));
%     %     rImageFinal = ImageFinal + i1.*p;
% %         disp(clock);
%          
%     end      
% %        disp(a1);
% end

C = gather(G);

end

