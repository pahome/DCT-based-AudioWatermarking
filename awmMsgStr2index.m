function index=awmMsgStr2index(opt)
% awmMsgStr2index: Convert message string (and the sync index) into codeword index
%
%	Usage:
%		index=awmMsgStr2index(opt)
%
%	Descripton:
%		awmMsgStr2index(opt) returns the indices of the codewords to be	embedded into the host signals
%
%	Example:
%		opt=awmOptSet;
%		index=awmMsgStr2index(opt);
%		fprintf('opt.syncIndex=%s\n', mat2str(opt.syncIndex));
%		fprintf('opt.msgStr=%s\n', opt.msgStr);
%		fprintf('awmMsgStr2index(opt)=%s\n', mat2str(index));

%	Roger Jang, 20150924

if nargin<1, selfdemo; return; end

temp=dec2base(abs(opt.msgStr), 4, 4)';
temp=temp(:)';
index=[opt.syncIndex, abs(temp)-abs('0')+1]';

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);
