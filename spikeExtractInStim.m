function [spikeStart,spikeEnd]=spikeExtractInStim(triggerTime,spikeAnnotation)

    sampleTime=4e-5;
    
    % defined the width of each spike (in total 3ms)
    spikeLeftWidth=1e-3;
    spikeRightWidth=2e-3;
    
    endTime=size(spikeAnnotation,1)*sampleTime;
    trigTimeDiff=diff(triggerTime);
    trigTimeDiff=horzcat(trigTimeDiff,endTime-triggerTime(end));
    
    pulseEndLocs=find(trigTimeDiff>40e-3);
    pulseStartLocs=pulseEndLocs+1;
    pulseStartLocs=horzcat(1,pulseStartLocs);
    pulseStartLocs(end)=[];
    
    
    numTrigs=size(pulseStartLocs,2);
    
    spikeLeftWidthIndex=round(spikeLeftWidth/sampleTime);
    spikeRightWidthIndex=round(spikeRightWidth/sampleTime);
    numChannels=size(spikeAnnotation,2);
    indexStart=round(triggerTime(pulseStartLocs)/sampleTime);
    indexEnd=round(triggerTime(pulseEndLocs)/sampleTime);
    
    spikeStart={};
    spikeEnd={};
    for i=1:numChannels
        timeStamp=[];
        for j=1:numTrigs
            timeStamp=vertcat(timeStamp,find(spikeAnnotation(indexStart(j):indexEnd(j),i))+indexStart(j)-1);
        end
        spikeStart{end+1}=timeStamp-spikeLeftWidthIndex;
        spikeEnd{end+1}=timeStamp+spikeRightWidthIndex;
    end


end