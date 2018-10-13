function [classes,avgSpikeWaveform,avgSpikeStd,badSpikesRatio]=spikeSorting(MEAdata,spikeStart,spikeEnd,channelID,index,toPlot)
    %spike sorting algorithm with SPC (super paragmagnetic clustering)
    %INPUT
    %MEAdata: 
    %spikeStart: an array of time stamp indicating the start time of each
    %spike
    %spikeEnd: an array of time stamp indicating the end time of each
    %spike
    %channelID: an array channel IDs (the channelIndex specified in the
    %beginning
    %Index : index of the channelID you would like to apply spike sorting
    %on
    
    %toPlot:boolean value indicating whether to plot the spike overlay of
    %each class

    
    % sampling time of the MEA
    samplingTime=4e-5;
    %specify the minimum interspike interval . Any spikes with inteval
    %shorter are undesired. Possibly there are two potential clusters
    %within the same class.
    badSpikeInterval=3e-3;
    
    
    spikeStartSingleChannel=spikeStart{index};
    spikeEndSingleChannel=spikeEnd{index};
    MEAdataSingleChannel=MEAdata(:,index);
    
    
    %extract features of the spike
    features=waveFeatures(MEAdataSingleChannel,spikeStartSingleChannel,spikeEndSingleChannel);
    if numel(features)==0
        disp('No Cluster')
        classes=zeros(1,numel(spikeStartSingleChannel));
    else
    %find clusters based on features. classes is an array of number
    %indicating the class of each spike
        classes=spikeCluster(features);
    end

    time=0:(spikeEndSingleChannel(1)-spikeStartSingleChannel(1));
    time=time.*samplingTime*1e3;
    
    % number of cluster being sorted
    classTypes= unique(classes,'sorted');
    
    badSpikesRatio=[];
    avgSpikeStd=[];
    avgSpikeWaveform=[];
    for i=1:numel(classTypes)
       spikeIndex=find( classes==classTypes(i));
       spikeStart_temp=spikeStartSingleChannel(spikeIndex);
       spikeEnd_temp=spikeEndSingleChannel(spikeIndex);
       badSpikesRatio(i)=sum((diff(spikeStart_temp).*samplingTime)<badSpikeInterval)./numel(spikeIndex);
      
       
       numSpikes=size(spikeStart_temp,1);
       valtemp=[];
       for j=1:size(spikeStart_temp,1)
           spike=MEAdataSingleChannel(spikeStart_temp(j):spikeEnd_temp(j));
           if (toPlot)
               if j==1
                   f=figure;
               else
                   figure(f);
               end
               plot(time,spike);
               hold on;	
           end
           valtemp(:,j)=spike;
       end
       
       if (toPlot)
           xlabel('Time (ms)');
           ylabel('Voltage(\muV)')
           title(strcat('Chn Num=',num2str(channelID(index)),', Class=',num2str(classTypes(i)),', Num of Spikes=',num2str(numSpikes),', Std=',num2str(avgSpikeStd(i))))
       end
       
       avgSpikeStd(i)=mean(std(valtemp,0,2));
       avgSpikeWaveform(i,:)=(mean(valtemp,2))';
       
       
    end

end