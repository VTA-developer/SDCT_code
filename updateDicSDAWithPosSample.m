function [dic, nc, v, effNum, posPatch] = updateDicSDAWithPosSample(posPatch, grayImg, param, tmplsize, patchsize, category, MaxSubClassNum, numOfNegPatches)

% --------- get negative image blocks -----
negPatch = getNegImgBlocks(grayImg, param, tmplsize, patchsize, numOfNegPatches);

% --------- construct dictionary ----------
nc        = [size(posPatch, 2), numOfNegPatches];
trainData = [posPatch'; negPatch'];
trainData = trainData ./ 255;

clear negPatch;
clear grayImg;

Y  = NNclassclustering(trainData, category, nc);
result_K       = zeros(1, MaxSubClassNum);
result_D       = zeros(1, MaxSubClassNum);

for count = 1:MaxSubClassNum
    H                   = count * ones(1,category);
    NH                  = get_NH(category, H, nc);
    [v, L, rankB, K, D] = SDA(category,Y,H,NH,2000);
    result_K(count)     = K;
    result_D(count)     = D;
end

%pick the sublcasses with the lowest conflicts value
[myK , myH]         = min(result_K);
H                   = myH * ones(1,category);
NH                  = get_NH(category, H, nc);
[v, L, rankB, K, D] = SDA(category, Y, H, NH, 2000);
v = real(v);

effNum = min(size(v, 2), myH);
dic    = constructDic(trainData(1:nc(1), :)', NH{1}, v(:, 1 : effNum));

low_cor         = (trainData(1:nc(1), :) * v(:, 1:effNum))';

paramSR.lambda2 = 0;
paramSR.mode    = 2;
paramSR.L       = length(low_cor(:,1));      
paramSR.lambda  = 0.01;

[SigmaX] = calSimX(category, Y);
for iter = 1:10
    
    alpha  = mexLasso(low_cor, dic, paramSR);
    alpha  = full(alpha);

    % ---------------  update Q ----------------
    [SimB]   = calSimB(category, Y, H, NH, alpha);
    [v, d]   = eig(1\SimB * SigmaX);
    v        = real(v);
    d        = real(d);
    d        = diag(d)';
    [d,ind]  = sort(d, 'descend');
    v        = v(:,ind);
    
    low_cor  = (trainData(1:nc(1), :) * v(:, 1:effNum))';
    low_cor  = real(low_cor);
    dic      = constructDic(trainData(1:nc(1), :)', NH{1}, v(:, 1 : effNum));
end