function [SimB] = calSimB(C, X, H, nh, alpha)

sampleData  = [];
for count = 1:C
    sampleData = [sampleData; X{count}];
end

numOfSample = size(sampleData, 1);
meanx       = mean(sampleData, 1);

% -------  calculate SigmaB -----------
numOfSubClass   = sum(H);
dim             = size(meanx , 2);
meansOfSubclass = zeros(numOfSubClass , dim);
probOfSubclass  = zeros(numOfSubClass , 1);

% get means of all subclasses
scount = 1;
for count = 1:C
    start = 0;
    for innercount = 1:H(count)
         meansOfSubclass(scount , :) = mean(X{count}((start + 1) : (start + nh{count}(innercount)), :) , 1);
         probOfSubclass(scount)      = nh{count}(innercount) / numOfSample;
         start = start + nh{count}(innercount);
         scount = scount + 1;
    end
end

SimB = zeros(dim , dim);
start  = 0;
for count = 1:(C - 1)
   for  innercount = 1:H(count)
       distOfMean = repmat(meansOfSubclass(start + innercount, :),numOfSubClass - start - H(count), 1) - ...
                    meansOfSubclass((H(count) + start + 1) : end, :);
       disposMean = distOfMean';
       for accMean = 1:(numOfSubClass - start - H(count))
            SimB = SimB + disposMean(:, accMean) * distOfMean(accMean , :) .* ...
                     probOfSubclass(start + innercount) .* ...
                     probOfSubclass(start + H(count) + accMean);
       end          
   end
   start = start + H(count);
end

meanSet = [];
for count = 1:H(1)
    meanSet = [meanSet, meansOfSubclass(count , :)'];
end

auxSigmB = X{1}' - meanSet * alpha;
SimB     = auxSigmB * auxSigmB' + SimB;