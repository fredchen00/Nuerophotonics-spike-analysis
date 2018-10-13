function plotMEASpike(MEAdata,time,spikelocation,triggerTime,channelIndex)
    % this functions takes the MEA data and trigger information and plot it
    % out along with spike anotated. the inde
    % INPUT
    %MEAdata: MEA data 
    %time: time corresponding to MEA data
    % spikelocation: a boolean array indicating spikes location. Its size
    % should be the same as MEAdata
    %triggerTime: time stamp of the trigger
    % channelIndex: specified which index in the MEA data to plot ( the
    % index referes to different channels on the MEA)
    
    %OUTPUT
    % a figure with the MEA data
    figure
    plot(time,MEAdata(:,channelIndex))
    hold on
    xcoord=find(spikelocation(:,channelIndex));
    plot(xcoord.*4e-5,MEAdata(xcoord,channelIndex),'*')
    hold on
    plot(triggerTime,(max(max((MEAdata)))*ones(1,size(triggerTime,2))),'x')
end