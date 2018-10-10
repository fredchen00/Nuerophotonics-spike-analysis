function [MEAdata,time,triggerTime]=dataParserByFileMCD(dirName,fileIndex,startTime,stopTime,channelindex)
%     Extracting raw MEA data from mcd files. you can mix all mcd files in
%     one file. Only the specified files (with fileIndex) will be
%     extracted. stopTime should not be longer than 715s.
%     input
%     dirName: directory that contains MCD files
%     fileIndex: the file number you would like to extract within the folder
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

    MEAtemp=[];
    MEAdata=[];
    
    triggerEntity=[];
    MEAEntity=[];
    
    firstTime=1;

    filename = dinfo(fileIndex).name;  %file name

    triggerAvailable=false;
    [nsresult] = ns_SetLibrary('nsMCDLibrary.dll');
    [nsresult,info] = ns_GetLibraryInfo();
    [nsresult, hfile] = ns_OpenFile(strcat(dirName,filename));
    [nsresult,entity] = ns_GetEntityInfo(hfile,1:61);

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
            [nsresult,~,data]=ns_GetAnalogData(hfile,realIndex,1,ceil(stopTime/sampleTime));
            timeIntervalIndexStart=ceil(startTime/sampleTime);
            timeIntervalIndexEnd=ceil(stopTime/sampleTime);
            timeScale=timeIntervalIndexStart:timeIntervalIndexEnd;
            MEAdata(j,:)=data(timeScale);
        end
        
        if(numel(triggerEntity)>0)
            [~,triggersDatatemp,~,~] = ns_GetEventData(hfile,1,1:triggerEntity.ItemCount);

            triggers = triggersDatatemp;
            triggers=double(triggers);
            mask=triggers>startTime;
            triggers=triggers.*mask;
            if stopTime<fileTime
                mask=triggers<stopTime;
                triggers=triggers.*mask;
            end
            triggers=nonzeros(triggers)'-startTime;
            triggerTime=triggers;
            timeaggregation=fileTime-startTime;

        end
        firstTime=0;
    else
        %concatanate the data to previous round array
        for j=1:numel(channelindex)
            realIndex=find(channelLabel==channelindex(j));
            if triggerAvailable
                realIndex=realIndex+1;
            end
            [nsresult,~,data]=ns_GetAnalogData(hfile,realIndex,1,ceil(stopTime/sampleTime));
            timeIntervalIndexStart=ceil(startTime/sampleTime);
            timeIntervalIndexEnd=ceil(stopTime/sampleTime);
            timeScale=timeIntervalIndexStart:timeIntervalIndexEnd;
            MEAdata(j,:)=data(timeScale);
        end

        if(numel(triggerEntity)>0)
            [~,triggersDatatemp,~,~] = ns_GetEventData(hfile,1,1:triggerEntity.ItemCount);

            triggers = triggersDatatemp;
            triggers=double(triggers);
            mask=triggers>startTime;
            triggers=triggers.*mask;
            if stopTime<fileTime
                mask=triggers<stopTime;
                triggers=triggers.*mask;
            end
            triggers=nonzeros(triggers)'-startTime;
            triggerTime=triggers;
            timeaggregation=fileTime-startTime;

        end

        MEAdata=cat(2,MEAdata,MEAtemp);
        MEAtemp=[];
    end


    MEAdata=MEAdata'.*1e6;
    time=1:size(MEAdata,1);
    time=(time').*4e-5;
end




