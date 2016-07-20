function output=awmAccuracy(folderName, opt, showPlot)
% awmAccuracy: Extract information from a music file.
%
%	Usage:
%		awmAccuracy(folderName, opt, showPlot);
%
%	Description:
%		awmAccuracy(folderName, opt, showPlot) returns the accuracy in folderName.
%			folderName: A folder which collect recorded songs. 
% 
%	Example:
%		folderName='recordedAudio/20151130/';
%		opt=awmOptSet;
%		opt.firstSyncFrameCount = 10;
%		opt.reSyncPeriod = 3;
%		avgacc=awmAccuracy(folderName, opt, 0);

%	Category: audio watermarking
%   Pa Home Chen, Zhe Cheng Fan, 20150712

if nargin<1, selfdemo; return; end
if nargin<2||isempty(opt), opt=awmOptSet; end
if nargin<3, showPlot=0; end

msg=awmMsgStr2index(opt);
fprintf('%s\n',folderName);
wavFile=dir([folderName filesep '*.wav']);
rightAns=opt.msgStr;
fileSpec=opt.fileSpec;
%% grab wavfiles based on the given fileSpec.
selected=logical(zeros(length(wavFile), 1));
for i=1:length(wavFile)
	temp=strsplit(wavFile(i).name,{'_','.wav'});
	right=ismember(fileSpec, temp);
	selected(i)=sum(right==1)==length(fileSpec);
end
wavFile=wavFile(selected);
output.wavFile=wavFile;
Accuracy=zeros(length(wavFile),length(opt.segmentDuration));
%% Run Accuracy
tic;
for j=1:numel(wavFile)
	fprintf('\n%s\n',[ folderName filesep wavFile(j).name]);
	fprintf('1st Sync:%d,resyncPeriod=:%d,resyncshift:%d,ScaleFactor:%f\n',opt.firstSyncFrameCount,opt.reSyncPeriod,opt.reSyncShift,opt.awmStrength);
	[wave,fs]=audioread([ folderName filesep wavFile(j).name]);
	wave=wave(:,1);
	for segmentsize=opt.segmentDuration
		overlap=segmentsize-1;
		shift=segmentsize-overlap;
		fprintf('segmentsize=%d sec,overlap=%d ',segmentsize,overlap);
		numSeg=ceil(((length(wave)/fs)-segmentsize)/(shift));
		correct=zeros(numSeg+1,1);
		for y=0:1:numSeg
			wave_all=wave((y*shift*fs)+1:min(((y*shift+segmentsize)*fs),length(wave)));
			[extractMsg] = awmExtract(wave_all,opt);
			output.wavFile(j).correctAns{y+1,segmentsize==opt.segmentDuration}=extractMsg.result;
			correct(y+1) = strcmp(rightAns,extractMsg.result);
		end
		Accuracy(j,segmentsize==opt.segmentDuration) = mean(correct);
	end
end
toc;
output.Accuracy=Accuracy;
output.opt=opt;
%%	Plot
if showPlot
	plot(opt.segmentDuration, 100*Accuracy', '.-'); grid on; box on
	title(['Accuracy plot']);
	legend(strPurify({wavFile.name}),'FontSize',12, 'location', 'northwest');
	xlabel('Segment duration (sec)');ylabel('Accuracy (%)');
	axis([min(opt.segmentDuration), max(opt.segmentDuration), 0, 100]);
	set(gca,'xtick', opt.segmentDuration);
end

% ====== Selfdemo
function selfdemo
mObj=mFileParse(which(mfilename)); % Parse the derscription of this mfile.
strEval(mObj.example); % self-demonstration.