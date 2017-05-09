function [waveformstruct] = generateLTEWaveform(waveformstruct)
%UNTITLED Summary of this function goes here
% % Configure the number of subframes to generate
numSubframes = 10;
NDLRB = waveformstruct.NDLRB;
% Establish the number of component carriers
numCC = length(NDLRB);

% Create transmission for each component carrier
enb = cell(1,numCC);
for i = 1:numCC
    enb{i} = lteRMCDL('R.5');
    enb{i}.NDLRB = NDLRB(i);
    enb{i}.Bandwidth = hNRBToBandwidth(NDLRB(i));
    enb{i}.TotSubframes = numSubframes;
    enb{i}.PDSCH.PRBSet = (0:enb{i}.NDLRB-1).';
    enb{i}.NCellID = 10;
end
if (numCC>1)

    F_c = zeros(1,numCC);
    BW_GB = zeros(1,numCC-1);
    F_offset = zeros(1,numCC);
    F_edge = zeros(1,numCC);
    spacing = zeros(1,numCC-1);

    for i = 1:2

        % Set center frequency of low carrier to 0 MHz
        if (i==1)
            F_c(1) = 0;
            disp(' ');
        end

%         fprintf('F_c_low: %1.3f MHz\n',F_c(1));

        % Calculate parameters for aggregated carriers
        for k = 2:numCC

            if (i==1)
                %  Calculate nominal guard band, TS36.101 5.6A-1
                BW_GB(k-1) = 0.05*max(enb{k-1}.Bandwidth,enb{k}.Bandwidth);
%                 fprintf('BW_GB: %0.3f MHz\n',BW_GB(k-1));

                % Calculate lower frequency offset, TS36.101 5.6A
                F_offset(k-1) = 0.18*NDLRB(k-1)/2 + BW_GB(k-1);
%                 fprintf('F_offset_low: %0.3f MHz\n',F_offset(k-1));
            end

            % Calculate lower bandwidth edge, TS36.101 5.6A
            F_edge(k-1) = F_c(k-1) - F_offset(k-1);
%             fprintf('F_edge_low: %0.3f MHz\n',F_edge(k-1));

            if (i==1)
                % Calculate component carrier spacing, TS36.101 5.7.1A
                spacing(k-1) = hCarrierAggregationChannelSpacing( ...
                    enb{k-1}.Bandwidth, enb{k}.Bandwidth);

%                 fprintf('spacing: %0.3f MHz\n',spacing(k-1));
            end

            % Not normative
            F_c(k) = F_c(k-1) + spacing(k-1);
%             fprintf('F_c_high: %0.3f MHz\n',F_c(k));

            if (i==1)
                % Calculate upper frequency offset, TS36.101 5.6A
                F_offset(k) = 0.18*NDLRB(k)/2 + BW_GB(k-1);
%                 fprintf('F_offset_high: %0.3f MHz\n',F_offset(k));
            end

            % Calculate upper bandwidth edge, TS36.101 5.6A
            F_edge(k) = F_c(k) + F_offset(k);
%             fprintf('F_edge_high: %0.3f MHz\n',F_edge(k));

        end

        if (i==1)
            % Calculate aggregated channel bandwidth, TS36.101 5.6A
            BW_channel_CA = F_edge(end) - F_edge(1);
%             fprintf('BW_channel_CA: %0.3f MHz\n',BW_channel_CA);

            shift = -BW_channel_CA/2 - F_edge(1);
%             fprintf(['Shift to center baseband' ...
%                         ' transmission: %0.3f MHz\n'],shift);
            F_c(1) = F_c(1) + shift;
        end

    end

    % Display edge parameters
%     for i = 1:numCC
%         fprintf('\nComponent Carrier %d:\n',i);
%         fprintf('   Lower band edge: %0.3f MHz\n', ...
%             F_c(i)-F_offset(i)+BW_GB(min(i,numCC-1)));
%         fprintf('   Upper band edge: %0.3f MHz\n', ...
%             F_c(i)+F_offset(i)-BW_GB(min(i,numCC-1)));
%     end

else

    BW_channel_CA = enb{1}.Bandwidth;
    F_c(1) = 0;

end
% Bandwidth utilization of 85%
bwfraction = 0.85;

% Calculate sampling rates of the component carriers
CCSR = zeros(1,numCC);
for i=1:numCC
    info = lteOFDMInfo(enb{i});
    CCSR(i) = info.SamplingRate;
end

% Calculate overall sampling rate for the aggregated signal
OSR = 2^ceil(log2((BW_channel_CA/bwfraction)/(max(CCSR)/1e6)));
SR = OSR*max(CCSR);
% fprintf('\nOutput sample rate: %0.3f Ms/s',SR/1e6);

% Calculate individual oversampling factors for the component carriers
OSRs = SR./CCSR;
% Generate component carriers
tx = cell(1,numCC);
for i=1:numCC
    tx{i} = lteRMCDLTool(enb{i},randi([0 1],1000,1));
    tx{i} = resample(tx{i},OSRs(i),1)/OSRs(i);
    tx{i} = hCarrierAggregationModulate(tx{i},SR,F_c(i)*1e6);
end

% Superpose the component carriers
waveform = tx{1};
for i = 2:numCC
    waveform = waveform + tx{i};
end 

%make waveform a row vector
%nx returns the length of the waveform (necessary for autocorrelation)
%x returns time vector
%spacing returns time vector spacing

waveformstruct.waveformt=waveform.'; %transpose into row vector\
%create time axis x, and spacing based on existing waveform parameters
waveformstruct.nx=length(waveform);
waveformstruct.SR = SR;
xend=((waveformstruct.nx-1)/waveformstruct.nx)*SR;
xend1=.01/xend;
xend2=xend*xend1;
waveformstruct.spacing=xend2/(waveformstruct.nx-1);
waveformstruct.x=0:waveformstruct.spacing:xend2;
waveformstruct.BW = BW_channel_CA; %returns bandwidth in MHz
end
