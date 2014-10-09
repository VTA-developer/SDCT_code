function [SigmaX] = calSimX(C, X)

% --------  calculate SigmaX ---------
sampleData  = [];
for count = 1:C
    sampleData = [sampleData; X{count}];
end

numOfSample = size(sampleData, 1);
meanx       = mean(sampleData, 1);
temp        = sampleData - repmat(meanx, numOfSample, 1);
SigmaX      = temp'* temp ./ numOfSample;