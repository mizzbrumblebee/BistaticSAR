function [SAR,waveformstruct] = getDataMatrix(waveformstruct,SAR,map)

global numpositions c numlevels fc
% c = 3e8;
k = 2*pi*fc/c;
rxydata = zeros(1,2*SAR.pl-1);
for r = 1:numpositions
    
    if r ==1   
%         toc;
        tf = strcmp(waveformstruct.samewaveform,'yes');
        if tf ==1
            [waveformstruct,SAR] = getRxx(SAR,waveformstruct);
        end
    end
     
    if r ==2
       elapsedtime = toc;
        format shortg;
        disp(elapsedtime);
    end
    if tf == 0
        waveformstruct = generateLTEWaveform(waveformstruct);
        [waveformstruct,SAR] = getRxx(SAR,waveformstruct);
%         disp(SAR.RxyMtx);
    end
   
    %generate autocorrelation matrix - find autocorrelation
    [R0total,RB,dR] = doRangeMath(SAR,map,r);
    %     Rxy = autocorrelation for that pulse
    %make matrix of autocorrelation with offsets
    SAR = getShiftedRxyMtx(SAR);
        for m2 = SAR.minsamples+1:SAR.Lp
            rxydata = zeros(size(rxydata));
	    %find range correspoinding to range bin and subtract ran to center pixel
            a1 = c*((m2-1)*waveformstruct.dtau) - R0total; 
            %find difference between that and dR
            a2 = a1- dR; 
	    %find boolean contour i.e. find all the pixels within that range of a half sample
            contour = abs(a2) < .5*c*waveformstruct.dtau; %boolean variable
            B = any(contour(:));
            if B == 1 %why bother doing this math if contour is empty
            %quantize that value
%             SAR.a4 = SAR.a2(SAR.contour)/(c*waveformstruct.dtau/SAR.SAR.numlevels);
            a3 = round((a2(contour)/(c*waveformstruct.dtau/numlevels))) + round(numlevels/2);
            aq = abs(a3 - (numlevels+1));
%             R1 = RB(:,:,r);
            ranges = RB(contour);
            
            %find RCS Constants corresponding to contour
            temp3 = SAR.clutter_mtx(contour).*exp(-1*1j*k*ranges);
            if numlevels ==1
               A = logical(aq);
               constantsum = sum(temp3(A)); 
               rxydata = constantsum.*SAR.RxyMtx; 
            else
                idx = arrayfun(@(m3) (aq == m3),1:numlevels,'uni',false);
                idx = cat(2,idx{:});
                constants = arrayfun(@(m3) temp3(idx(:,m3)),1:numlevels,'uni',false);
                constantsum = arrayfun(@(m3) sum(constants{m3}),1:numlevels);
                rxydata = sum(bsxfun(@times,constantsum.',SAR.RxyMtx));   
            end
            %return matrix * phase correction
            %for first sample, take that data to the end and put into data
            %matrix
            %recurring sum over data matrix
            startpoint = SAR.center_sample - ((m2-SAR.minsamples)-1); 
            endpoint = startpoint + SAR.pl -1;
            SAR.datamatrix(r,:) = SAR.datamatrix(r,:) + rxydata(startpoint:endpoint);
            end    
        end
SAR.datamatrix2(r,:) = resample(SAR.datamatrix(r,:),10,1);
end
end