function [au2]=awmEmbed(au, awmOpt)
% awmEmbed: Embed information in an audio file.
%
%	Usage:
%		awmEmbed(auFile, awmOpt);
%
%	Description:
%		awmEmbed(auFile, awmOpt) returns the audio file with embedded information.
%			auFile: An audio file which you want to hide information. 
% 
%	Example:
%		auFile='originalAudio/classical.mp3';
%       awmOpt=awmOptSet;
%		au=awmEmbed(auFile, awmOpt);
%		audiowrite('tmp.wav',au.signal,au.fs);
%		sound(au.signal,au.fs);

%	Category: audioWatermarking encoding
%   Pa Home Chen, Zhe Cheng Fan, Kai Yu, 20151113

if nargin<1, selfdemo; return; end
if nargin<2||isempty(awmOpt), awmOpt=awmOptSet; end
if ischar(au), au=myAudioRead(au); end

%% Start embedding information (AWM)
fprintf('Embed function: %s\n',awmOpt.method);
if size(au.signal, 2) == 1
    output = feval(awmOpt.embedFcn, au.signal(:, 1), au.fs, awmOpt);
else
    output(:, 1) = feval(awmOpt.embedFcn, au.signal(:, 1), awmOpt);
    output(:, 2) = feval(awmOpt.embedFcn, au.signal(:, 2), awmOpt);
end
au2=au; au2.signal=output;
if strcmp(awmOpt.method, 'dct')
    %% Normalization -1~+1
    maxValue=max(max(abs(output)));
    au2.signal=output/maxValue;
end
end

% ====== Selfdemo
function selfdemo
mObj=mFileParse(which(mfilename)); % Parse the derscription of this mfile.
strEval(mObj.example); % self-demonstration.
end