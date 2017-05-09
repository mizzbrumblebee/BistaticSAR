function [waveformstruct,SAR] = getRxx(SAR,waveformstruct)
%     global pl 
    %find pulse record
    i1w = round(waveformstruct.nx*waveformstruct.fraction);
    i2w = i1w + SAR.pl -1;
%     offset = round(waveformstruct.nx*diff)*offsetnum;
    waveformstruct.pulse = waveformstruct.waveformt(i1w:i2w);

    
    %find peak value (norm)
    waveformstruct.hp=conj(fliplr(waveformstruct.pulse));
    RHSp=conv(waveformstruct.hp,waveformstruct.pulse);
    waveformstruct.E= real(max(RHSp));
    
    SAR.RxxMtx=conv(waveformstruct.pulse,waveformstruct.hp)/waveformstruct.E;
    
end

