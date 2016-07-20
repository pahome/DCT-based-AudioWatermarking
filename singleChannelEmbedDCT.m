function output=singleChannelEmbedDCT(y, awmOpt)
% singleChannelEmbedDCT.m: embed watermark based on DCT
% 
%	Usage:
%		singleChannelEmbedDCT(au, awmOpt);
%
%	Description:
%		singleChannelEmbedDCT(au, awmOpt) returns the audio vector which is embedded information.
%		musicFile: A audio file which you want to embed information. 
% 
%	Example:
%		musicFile='originalAudio/rock.mp3';
%       [au,fs]=audioread(musicFile);
%       if size(au, 2) > 1, au=au(:, 1); end
%       opt=awmOptSet('dct');
%		[awm]=singleChannelEmbedDCT(au, opt);
%		sound(awm,fs);
%		audiowrite('tmp.wav',awm(:,1),fs);
%
%	Category: audio watermarking
%   Pahome, 20151202

if nargin<1, selfdemo; return; end
if nargin<2, awmOpt=awmOptSet('dct'); end
%% parameters
output = zeros([floor(length(y)/awmOpt.frameSize)*awmOpt.frameSize, 1]);
bandIdx = awmOpt.bandIdx;
msg=awmMsgStr2index(awmOpt);	% Index into codewords 5566+21422332...
wmark=zeros(awmOpt.frameSize, 1);
criticalBandCount=size(awmOpt.criticalBand, 1);
bandGain=awmOpt.minBandGain*ones([criticalBandCount, 1]);
codeword=awmOpt.codeword;   % 6x512
%% embed
for i=1:awmOpt.frameSize:(length(y)-awmOpt.frameSize)
	frameDCT = dct(y(i:(i+awmOpt.frameSize-1)));
	wmark=0*wmark;
	msgIndex=mod((floor(i/awmOpt.frameSize)), length(msg))+1; % i=1, msgIndex=1,i=2, msgIndex=2...i=28, msgIndex=28,i=29, msgIndex=1
	wmark(bandIdx(1):bandIdx(2))=codeword(msg(msgIndex),:);
	for j=1:criticalBandCount
		wmark(awmOpt.criticalBand(j,1):awmOpt.criticalBand(j,2)) = bandGain(j)*wmark(awmOpt.criticalBand(j,1):awmOpt.criticalBand(j,2));
	end
	frameDCT=frameDCT+wmark;
	for j=1:criticalBandCount
		bandGain(j)=awmOpt.awmStrength*max(frameDCT(awmOpt.criticalBand(j,1):awmOpt.criticalBand(j,2)));		% New bandGain for the next frame
	end
	bandGain=max(bandGain,awmOpt.minBandGain);
	output(i:(i+awmOpt.frameSize-1))=idct(frameDCT);
end

function selfdemo
mObj=mFileParse(which(mfilename)); % Parse the derscription of this mfile.
strEval(mObj.example); % self-demonstration.