function [spikerateData,spikelocation]=spikecount(MEAdata,triggerTime,channelindex,windowSize,plotrate)
    thresholdfactor=4;
    %1ms
    minpeakdist=25;
    %1.1ms
    maxWidth=35;
    
    spikerateData=[];
    spikelocation=[];
    stepsize=windowSize/4e-5;
    numsteps=floor(size(MEAdata,1)/stepsize);
    numchannels=size(channelindex,2);
    for j=1:numchannels
        singleMEAdata=MEAdata(:,j);
        for i=1:numsteps
            startindex=round(((i-1)*stepsize)+1);
            endindex=round((i*stepsize));
            temp=singleMEAdata(startindex:endindex);
            thresholdlevel=thresholdfactor*median(abs(temp)./0.6745);
            %eliminate spikes that have FWHM larger than 1ms
            [~,tempspikesdownlocs]=findpeaks(-temp,'MinPeakHeight',thresholdlevel,'MinPeakDistance',minpeakdist,'MinPeakProminence',thresholdlevel*0.8,'WidthReference','halfheight','MaxPeakWidth',maxWidth);
            [~,tempspikesuplocs]=findpeaks(temp,'MinPeakHeight',thresholdlevel,'MinPeakDistance',minpeakdist,'MinPeakProminence',thresholdlevel*0.8,'WidthReference','halfheight','MaxPeakWidth',maxWidth);
            
            
            spikeindices=[];
            if ((size(tempspikesuplocs,1)>0) || (size(tempspikesdownlocs,1)>0)) 
                tempspikeslocs=vertcat(tempspikesuplocs,tempspikesdownlocs);

                tempspikeslocs = sort(tempspikeslocs);
                conflictlocs=find((diff(tempspikeslocs,1,1)<minpeakdist));
                eliminatlocs=[];
                
                
                for loc=1:size(conflictlocs,1)
                    %check which conflicting points have higher amplitude
                    if abs(temp(tempspikeslocs(conflictlocs(loc))))>abs(temp(tempspikeslocs(conflictlocs(loc)+1)))
                        eliminatlocs=vertcat(eliminatlocs,conflictlocs(loc)+1);
                    else
                        eliminatlocs=vertcat(eliminatlocs,conflictlocs(loc));
                    end
                end
                %empty the indices that are supposed to be discarded
                if size(eliminatlocs,1)>0
                    tempspikeslocs(eliminatlocs)=[];
                end
                halfAmp=abs(temp(tempspikeslocs)./2);
                numspikes=size(tempspikeslocs,1);

                for spikeindex=1:numspikes
                    %counting number of point below half max within the defined
                    %width
                    if (tempspikeslocs(spikeindex)+round(maxWidth/2))<size(temp,1)
                        rightwing=sum(abs(temp(tempspikeslocs(spikeindex):(tempspikeslocs(spikeindex)+round(maxWidth/2))))<halfAmp(spikeindex))>0;
                    else
                         rightwing=sum(abs(temp(tempspikeslocs(spikeindex):end))<halfAmp(spikeindex))>0;
                    end
                    if(tempspikeslocs(spikeindex)>round(maxWidth/2))
                        leftwing=sum(abs(temp((tempspikeslocs(spikeindex)-round(maxWidth/2)):tempspikeslocs(spikeindex)))<halfAmp(spikeindex))>0;
                    else
                        leftwing=sum(abs(temp(1:tempspikeslocs(spikeindex))<halfAmp(spikeindex)))>0;
                    end
                    if(rightwing>0&&leftwing>0)
                        spikeindices=vertcat(spikeindices,tempspikeslocs(spikeindex));
                    end
                end
            
            

            end
            spikerateData(i,j)=size(spikeindices,1)/windowSize;
            spikelocationtemp=zeros(endindex-startindex+1,1);
            spikelocationtemp(spikeindices,1)=1;
            spikelocation(startindex:endindex,j)=spikelocationtemp;
        end
    end
    
    if plotrate
        timeAxis=1:numsteps;
        figure
        for i=1:numchannels
            %subplot(numchannels,1,i);
            plot(timeAxis.*windowSize,spikerateData(:,i),'LineWidth',2)
            hold on
        end

        plot(triggerTime,max(max(spikerateData))*ones(1,size(triggerTime,2)),'x')
        xlabel('Time (s)')
        ylabel('Spike Rate (spikes/s)')
        legend(num2str(channelindex'))
    end
    
end