function results=MEAfilter(MEAdata,cf1,cf2,plotcomp)
%     applying bandpass filter to raw MEA data
%     input
%     MEAdata: Array of raw MEA data 
%     cf1: lower cutoff frequency
%     cf2: higher cutoff frequency
%     plotcomp: plot filtered data
%     
%     return:
%     results: Array filtered  MEA data
    
    Fs=1/4e-5;
    %60Hz notch filter with Q factor of 35
    wo = 60/(Fs/2); 
    bw = wo/20;
    [b,a] = iirnotch(wo,bw);
    
    
   bpFiltlow = designfilt('lowpassiir', ...        % Response type
       'PassbandFrequency',0.9*cf2, ...     % Frequency constraints
       'StopbandFrequency',cf2, ...
       'PassbandRipple',1, ...          % Magnitude constraints
       'StopbandAttenuation',55, ...
       'DesignMethod','cheby2', ...      % Design method
       'SampleRate',Fs);
   
    bpFilthigh = designfilt('highpassiir', ...       % Response type
       'StopbandFrequency',0.9*cf1, ...     % Frequency constraints
       'PassbandFrequency',cf1, ...
       'StopbandAttenuation',55, ...    % Magnitude constraints
       'PassbandRipple',1, ...
       'DesignMethod','cheby2', ...     % Design method
       'SampleRate',Fs);
   

    results=filtfilt(b,a,MEAdata);
    results=filtfilt(bpFiltlow,results);
    results=filtfilt(bpFilthigh,results);
    
    index=1:size(results,2);
    if plotcomp
%         fvtool(b,a);
%         fvtool(bpFilthigh)
%         fvtool(bpFiltlow)
        figure
        plot(results)
        hold on
        plot(MEAdata)
        label=vertcat(cellstr(num2str(index')),cellstr(strcat(num2str(index'),repmat('raw',size(results,2),1))));
        legend(label)
    end
end