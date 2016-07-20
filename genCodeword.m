function [output]=genCodeword(num,N,codeword)
%% generate num of codeword between 1,-1 and Length=N
% if num==1
%     fprintf('Number of rows of codewords should greater than 1.\n');
%     output=[];
%     return;
% end
if nargin<3
    codeword=(-1).^randi(2, 1, N);
end
temp=codeword;
numofCodeword=0;
while(1)
    %c=temp(randi([1 6]),:);
    b=(-1).^randi(2, 1, N);
    %b=c(randperm(N));
    if (temp*b')==0
        temp=[temp;b];
        numofCodeword=numofCodeword+1;
    end
    if numofCodeword==num
        fprintf('Finished.\n');
        break;
    end
end
output=temp;