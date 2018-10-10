function [MEAdata,time,triggerTime]=dataParserMCD(dirName,startTime,stopTime,channelindex)

% Extracting raw MEA data from mcd files. All partitioned MCD files should be included in the same folder.Do not mix other MCD files in the folder
%     input
%     dirName: directory that contains MCD files
%     startTime: the beginning of the extraction time
%     stopTime: end of the extraction time
%     channelIndex: channels that would like to be extracted
%     
%     return
%     MEAdata: array of raw MEA data (number of channels X data length)
%     time: timestamp of MEA data
%     triggerTime: timestamp of digital triggers (s) 
%     
%     ex:dataParserMCD('D:\MEA data control exp\oct 6 2018\cereb1\t1\485',5,100,[11,12,13,14,15,16,21,22,23])
       
   


    
    
    dinfo = dir(char(dirName+"*.mcd"));
    
    %initialize params for reading data
    fileTime=715.4;
    sampleTime=4e-5;
    startFileIndex=ceil(startTime/fileTime);
    endFileIndex=ceil(stopTime/fileTime);
    
    triggerEntity=[];
    MEAEntity=[];
    
    MEAtemp=[];
    MEAdata=[];
    triggerTime=[];
    
    triggerAvailable=false;
    [nsresult] = ns_SetLibrary('nsMCDLibrary.dll');
    [nsresult,info] = ns_GetLibraryInfo();

    
    firstTime=1;
    timeCursor=(startFileIndex-1)*(fileTime);
    for fileIndex = startFileIndex : endFileIndex
        filename = dinfo(fileIndex).name;  %file name
        
        timeIntervalStart=(startTime-timeCursor);
        if(timeIntervalStart<0)
            timeIntervalStart=0;
        end
        timeIntervalStop=(stopTime-timeCursor);
        
        if(timeIntervalStop>fileTime)
            timeIntervalStop=fileTime;
        end
        
        
        [nsresult, hfile] = ns_OpenFile(strcat(dirName,filename));
        [nsresult,entity] = ns_GetEntityInfo(hfile,1:61);
        
        fileLength=entity(2).ItemCount;
        if (timeIntervalStop/sampleTime)>fileLength
            timeIntervalStop=fileLength*sampleTime;
        end
        
        
        firstElement=strsplit(entity(1).EntityLabel,' ');
        if(strcmp(firstElement{4}(1:4),'trig'))
            triggerEntity=entity(1);
            MEAEntity=entity(2:61);
            triggerAvailable=true;
        else
            MEAEntity=entity(1:60);
        end
        
        
        if firstTime==1
            %first round :initializing arrays
            for i=1:numel(MEAEntity)
                elements=strsplit(MEAEntity(i).EntityLabel,' ');
                
                temp=str2num(elements{4});
  
                channelLabel(i)=temp;

            end
            
            
            for j=1:numel(channelindex)
                realIndex=find(channelLabel==channelindex(j));
                if triggerAvailable
                    realIndex=realIndex+1;
                end
                
                
                [nsresult,~,data]=ns_GetAnalogData(hfile,realIndex,1,ceil(timeIntervalStop/sampleTime));
                
                timeIntervalIndexStart=ceil(timeIntervalStart/sampleTime);
                timeIntervalIndexEnd=ceil(timeIntervalStop/sampleTime);
                timeScale=(timeIntervalIndexStart+1):timeIntervalIndexEnd;
                MEAdata(j,:)=data(timeScale);
                  
            end
            
            if(numel(triggerEntity)>0)
                [~,triggersDatatemp,~,~] = ns_GetEventData(hfile,1,1:triggerEntity.ItemCount);
                
                triggers = triggersDatatemp;
                triggers=double(triggers);
                mask=triggers>timeIntervalStart;
                triggers=triggers.*mask;
                if timeIntervalStop<fileTime
                    mask=triggers<timeIntervalStop;
                    triggers=triggers.*mask;
                end
                triggers=nonzeros(triggers)'-timeIntervalStart;
                triggerTime=triggers;
                timeaggregation=fileTime-timeIntervalStart;
                
            end
            firstTime=0;
        else
            %concatanate the data to previous round array
            for j=1:numel(channelindex)
                realIndex=find(channelLabel==channelindex(j));
                if triggerAvailable
                    realIndex=realIndex+1;
                end
                [nsresult,~,data]=ns_GetAnalogData(hfile,realIndex,1,ceil(timeIntervalStop/sampleTime));
                timeIntervalIndexStart=ceil(timeIntervalStart/sampleTime);
                timeIntervalIndexEnd=ceil(timeIntervalStop/sampleTime);
                timeScale=(timeIntervalIndexStart+1):timeIntervalIndexEnd;
                MEAtemp(j,:)=data(timeScale);
            end
            
            if(numel(triggerEntity)>0)
                [~,triggersDatatemp,~,~] = ns_GetEventData(hfile,1,1:triggerEntity.ItemCount);
                triggers =triggersDatatemp;
                triggers=double(triggers);
                if timeIntervalStop<fileTime
                    mask=triggers<timeIntervalStop;
                    triggers=triggers.*mask;
                end
                
                triggers=(nonzeros(triggers))'+timeaggregation;
                triggerTime=cat(2,triggerTime,triggers);
                timeaggregation=timeaggregation+fileTime;
                
            end

            MEAdata=cat(2,MEAdata,MEAtemp);
            MEAtemp=[];
        end
        timeCursor=timeCursor+fileTime;
    end
    MEAdata=MEAdata';
    time=1:size(MEAdata,1);
    time=(time').*4e-5;
end




