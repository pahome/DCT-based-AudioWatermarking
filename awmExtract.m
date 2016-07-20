function [awm] = awmExtract(au, awmOpt)
% awmExtract:extract watermark based on awmOptSet.extractFcn
% 
%	Usage:
%		awmExtract(au, awmOpt);
%
%	Description:
%		awmExtract(au, awmOpt) returns the wave file which is embedded information.
%		musicFile: A music file which you want to extract information. 
% 
%	Example:
%		musicFile='tmp.wav';
%       opt=awmOptSet;
%		[awm]=awmExtract(musicFile, opt);

%	Category: audio watermarking
%   Pa Home Chen, Chi Kai Yu, Zhe Cheng Fan, 20150729

if nargin<1, selfdemo; return; end
if nargin<2||isempty(awmOpt), awmOpt=awmOptSet; end
if ischar(au), au=myAudioRead(au); wave=au.signal(:,1);else wave=au; end
if size(wave,2)==2 frpintf('Warning: signal should be single-channel.\n');wave=wave(:,1); end

%fprintf('Extract function: %s\n',awmOpt.extractFcn);
awm = feval(awmOpt.extractFcn, wave, awmOpt);
end

function selfdemo
mObj=mFileParse(which(mfilename)); % Parse the derscription of this mfile.
strEval(mObj.example); % self-demonstration.
end