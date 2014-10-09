function sortedtrain = NNclassclustering(trainingdata, C, nc)
% first step: find two samples (element 1 and element 2) in each class
% which have the largest distance between each other
%
% second step: sort the data such that: element 1 and element 2 are the
% 1st and nth sample in the sorted training data, and 1~n/2 samples are near
% element 1 and n/2+1~n samples are near element2 

% input: trainingdata: n-by-p matrix, all the data
%        C: number of classes
%        nc: c-by-1 matrix containing the number of samples for each class
% output:
%        trainingdata: the sorted training data
%

[n , p]     = size(trainingdata);
distMat     = cell(1, C);
sortedtrain = cell(1, C);

start     = 0;
for count = 1 : C
    
    distMat{count} = zeros(nc(count), nc(count));
    X              = trainingdata(start + 1:start + nc(count) , :);

    for i = 1 : nc(count) - 1
        distMat{count}((i + 1):end, i) = sum(((repmat(X(i,:), nc(count) - i, 1) - X((i + 1):end, :)).^2), 2);
    end
    
    distMat{count} = distMat{count} + distMat{count}';
    
    [maxVal_vec, idx_vec] = max(distMat{count});
    [maxVal,         idx] = max(maxVal_vec);
    
    row = idx_vec(idx);
    col = idx;
    
    sortedtrain{count}         = zeros(nc(count), p);
    sortedtrain{count}(1, :)   = X(row, :);
    sortedtrain{count}(end, :) = X(col, :);
    
    for i = 1 : nc(count)
        distMat{count}(i, i) = inf;
    end
    
    [startval , startidx] = sort(distMat{count}(row, :));
    
    medidx                                        = floor((nc(count) - 2)/2);
    sortedtrain{count}(2:(medidx + 1), :)         = X(startidx(1:medidx), :);
    sortedtrain{count}((medidx + 2):(end - 1), :) = X(startidx((medidx + 1):(end - 2)), :);
    
    start    = start + nc(count);
end



