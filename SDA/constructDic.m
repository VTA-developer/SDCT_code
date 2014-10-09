function [dic] = constructDic(X, nh, V)

numOfSubClass = length(nh);
dim           = size(V , 2);
dic           = zeros(dim, numOfSubClass);
V             = V';

start = 0;
for count = 1:numOfSubClass
    meanx         = mean(X(:, (start + 1) : (start + nh(count))), 2);
    dic(:, count) = V * meanx;
    start         = start + nh(count);
end