function [awm] = singleChannelExtractDCT(au, awmOpt)
% singleChannelExtractDCT:
% 
%	Usage:
%		singleChannelExtractDCT(au, opt);
%
%	Description:
%		singleChannelExtractDCT(au, opt) returns the wave file which is embedded information.
%		au: A music file which you want to extract information. 
% 
%	Example:
%		musicFile='tmp.wav';
%       opt=awmOptSet;
%		[Ans]=singleChannelExtractDCT(musicFile, opt);

%	Category: audio watermarking
%   Pa Home Chen, Zhe Cheng Fan, 20150729

if nargin<1, selfdemo; return; end
if nargin<2||isempty(awmOpt), awmOpt=awmOptSet; end
if ischar(au), au=myAudioRead(au); wave=au.signal(:,1);else wave=au; end
if size(wave,2)==2 fprintf('Warning: signal should be single-channel.\n');wave=wave(:,1); end
%% Set up initial Values
syncIndex=awmOpt.syncIndex;
msgStr=awmOpt.msgStr;
msgStrLen=length(msgStr);
frameSize=awmOpt.frameSize;
bandIdx=awmOpt.bandIdx;
criticalBand=awmOpt.criticalBand;
awmStrength=awmOpt.awmStrength;
codeword=awmOpt.codeword;
criticalBandCount=size(awmOpt.criticalBand, 1);
bandGain = awmOpt.awmStrength*ones([criticalBandCount, 1]);
reSyncPeriod = awmOpt.reSyncPeriod;
reSyncShift = awmOpt.reSyncShift;
firstSyncFrameCount = awmOpt.firstSyncFrameCount;
allBitCorre = zeros([floor(length(wave)/frameSize)*length(msgStr), 1]);
extractMsg = zeros([floor(length(wave)/frameSize), 1]); % 1~6 sequence
extractedMsgLen = 0;
reallocCount = 0;
Correlation=zeros(2,frameSize);%row 1 for correlation , row2 for bandGain_Best
msg=awmMsgStr2index(awmOpt);%556621422332...
%% First synchronization
for i=1:frameSize
    GainVal=0;
    frameDCT=dct(wave(i:i+frameSize-1));
    for k = 1:size(criticalBand, 1)
            bandGain(k) = awmStrength * max(frameDCT(criticalBand(k,1):criticalBand(k,2)));
    end
    bandGain_First = bandGain;
    for j=1:firstSyncFrameCount
        frameDCT = dct(wave((i+j*frameSize):(i+(j+1)*frameSize-1)));    % starting from 2nd frame.
        wmark = frameDCT;
        for k = 1:size(criticalBand, 1)
            wmark(criticalBand(k,1):criticalBand(k,2)) = wmark(criticalBand(k,1):criticalBand(k,2)) / bandGain(k);
        end
        wmark = wmark(bandIdx(1):bandIdx(2));
        sim = codeword * wmark; %用內積來求相似度similarity 6x1
        [val, ~] = max(sim);
        GainVal = GainVal + val;
        for k = 1:size(criticalBand, 1)
            bandGain(k) = awmStrength * max(frameDCT(criticalBand(k,1):criticalBand(k,2)));
        end
    end
    Correlation(1,i)=GainVal;
    Correlation(2:2+size(bandGain,1)-1,i)=bandGain_First;
end
% setup first bandGain
[~,maxIdx]=max(Correlation(1,:));
firstFrame=dct(wave(maxIdx:maxIdx+frameSize-1));
firstFrame=firstFrame(bandIdx(1):bandIdx(2));
[~, id]=max(codeword * firstFrame); 
allBitCorre(extractedMsgLen*msgStrLen+1:extractedMsgLen*msgStrLen+5)=codeword * firstFrame;
extractMsg(extractedMsgLen+1) = id;
extractedMsgLen = extractedMsgLen+1;
bandGain = Correlation(2:2+size(bandGain,1)-1,maxIdx);
idx = maxIdx+frameSize;
resyncCorrelation=zeros(3,2*reSyncShift+1); %row1 for correlation, row2 for sample idx, row3 for bandGain.
%% Extract hidden information
while(idx<(length(wave)-frameSize))
    frameDCT = dct(wave(idx:(idx+frameSize-1)));
    wmark = frameDCT;
    for j = 1:size(criticalBand, 1)
        wmark(criticalBand(j,1):criticalBand(j,2)) = wmark(criticalBand(j,1):criticalBand(j,2)) / bandGain(j);
    end
    wmark = wmark(bandIdx(1):bandIdx(2));
    sim = codeword * wmark;
    [~, msgId] = max(sim);%sim = similarity ,codewords裡面內積最高的那列就是它本身代表的數字
	allBitCorre(extractedMsgLen*msgStrLen+1:extractedMsgLen*msgStrLen+5)=sim;
    extractMsg(extractedMsgLen+1) = msgId;
    extractedMsgLen = extractedMsgLen+1;
    for j = 1:size(criticalBand, 1)
        bandGain(j) = awmStrength * max(frameDCT(criticalBand(j,1):criticalBand(j,2)));
    end
    reallocCount = reallocCount + 1;
    %Resync
    if(reallocCount >= reSyncPeriod)
        resyncCorrelation=0*resyncCorrelation;
        i = (idx-reSyncShift);
        resyncId=1;
        while ((i+2*frameSize-1)<length(wave) & i<=(idx+reSyncShift))
            frameDCT = dct(wave(i:(i+frameSize-1)));
            for j = 1:size(criticalBand, 1)
                bandGain(j) = awmStrength*max(frameDCT(criticalBand(j,1):criticalBand(j,2)));
            end
            frameDCT = dct(wave((i+frameSize):(i+2*frameSize-1)));
            wmark = frameDCT;
            for j = 1:size(criticalBand, 1)
                wmark(criticalBand(j,1):criticalBand(j,2))=wmark(criticalBand(j,1):criticalBand(j,2))/bandGain(j);
            end
            wmark = wmark(bandIdx(1):bandIdx(2));
            sim = codeword * wmark;
            [val, ~] = max(sim);
            resyncCorrelation(1,resyncId)=val;
            resyncCorrelation(2,resyncId)=i;
            resyncCorrelation(3:3+size(bandGain,1)-1,resyncId)=bandGain;
            resyncId=resyncId+1;
            i = i + 1;
        end
        reallocCount = 0;
        [~,maxId]=max(resyncCorrelation(1,1:resyncId-1));
        idx = resyncCorrelation(2,maxId);
        bandGain = resyncCorrelation(3:3+size(bandGain,1)-1,maxId);%bestBandGain;
    end
	idx = idx + frameSize;
end
%	Sum of correlation of each corresponding index
numOfawm=floor(extractedMsgLen/length(msg));
idOfAwm=numOfawm*length(msg)*length(msgStr);
allBitCorre4reshape=reshape(allBitCorre(1:idOfAwm),length(msg)*length(msgStr),numOfawm);
allBitCorre4reshape(1:(length(allBitCorre)-idOfAwm),numOfawm+1)=allBitCorre(idOfAwm+1:end);
sumOfCorre=reshape(sum(allBitCorre4reshape'),length(msgStr),length(msg));
[~,idSumAll]=max(sumOfCorre);
awm.extractMsgOriginal=extractMsg;
extractMsg=[idSumAll';idSumAll'];
extractedMsgLen=length(extractMsg);
%% Decode Msg from extractMsg
ans10base=zeros(length(msgStr), ceil(length(wave)/1024) );
ansIndex=0;         
numofSync=0;
syncLength=length(awmOpt.syncIndex);%5566
i = 1;
while(i <= (extractedMsgLen-length(msg)+1))%28
    if msg(1:syncLength)==extractMsg(i:i+syncLength-1)%check if isequal(Sync.)
        for len=4:4:length(msg)-syncLength
            ansIndex = ansIndex+1;
            a = (extractMsg((i+len):(i+len+3))-1)';
            ans10base(ansIndex) = (sum(a .* (4 .^ (length(a)-1:-1:0)))); % 4-base to ASCII code.
        end
        numofSync = numofSync+1;
        i = i + length(msg);
    else
        i = i + 1;
    end
end
%% Vote for answer
Ans=zeros(1,length(msgStr));
for msgIndex=1:length(msgStr)
    [a,b]=hist(ans10base(msgIndex, (1:numofSync)), unique(ans10base(msgIndex,(1:numofSync)))); %
    [~,maxId] = max(a);
    if isempty(b)
        Ans='noSync';
        break;
    end
    Ans(msgIndex) = b(maxId);
end
%%	Append parameters to output.
awm.result=char(Ans);
awm.extractMsg=extractMsg;
awm.allBitCorre=allBitCorre;
fprintf('%s ',char(Ans));
function selfdemo
mObj=mFileParse(which(mfilename)); % Parse the derscription of this mfile.
strEval(mObj.example); % self-demonstration.