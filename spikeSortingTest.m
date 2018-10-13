

%directory where the mcd files are stored. Recommend to group all files
%into separate folder. Some recordings divided into different
%files. These files can be identified by the name containing  0001 or 0002.
%Place those files along with its main file in one folder and run
%dataParserMCD. 
%Another way is the run dataParserByFileMCD by specifying the file index 
%you would like to process in the folder. This method does not require all
%files in different directory.

dirName='C:\Users\Fred_PC\Documents\Multi Channel Systems\Sept 05 2018\';
%all possible channels
channelID=[11 12 13 15 16 21 22 23 24 25 26 31 32 33 34 35 36 41 42 43 44 45 46 ...
          51 52 53 54 55 56 61 62 63 64 65 66 71 72 73 74 75 76 81 82 83 84 85 86 ...
         91 92 93 94 95 96 101 102 103 104 105 106];

     
startTime=10;
stopTime=startTime+120;

%bandpass region of the filter
cf1=300;
cf2=3000;


%parse data within the specified time
[MEAdata,time,triggerTime]=dataParserMCD(dirName,startTime,stopTime,channelID);
%parse data in the specified file index in the folder within the
%specified time
%[MEAdata,time,triggerTime]=dataParserByFileMCD(dirData,fileIndex,startTime,stopTime,channelIndex);

%filtered MEA data with a bandpass filter
filteredData=MEAfilter(MEAdata,cf1,cf2,false);

%spike detection
[~,spikeAnnotation]=spikecount(filteredData,triggerTime,channelID,2,false);

%plot out the spikes along with annotation indicating the spikes
%location
%plotMEASpike(filteredData,time,spikeAnnotation,triggerTime,4)



%extract the start and end time of each spike 
[spikeStart,spikeEnd]=spikeExtractInStim(triggerTime,spikeAnnotation);

% sort all channels indicated in the channelIndex array
[classes,avgSpikeWaveform,avgSpikeStd,badSpikesRatio]=spikeSorting(filteredData,spikeStart,spikeEnd,channelID,index,true);