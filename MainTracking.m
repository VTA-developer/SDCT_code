% MainTracking
clear;
clc;

addpath('./Affine Sample Functions');
addpath('./SDA');

% ---------- config parameters -------------
p               = [354, 38, 95, 65, 0];                             % the location of the target in the first frame.
opt             = struct('numsample',400, 'affsig',[16,16,0,0,0,0]);% affsig(1) = x translation (pixels, mean is 0)
                                                                    % affsig(2) = y translation (pixels, mean is 0)
                                                                    % affsig(3) = x & y scaling
                                                                    % affsig(4) = rotation angle
                                                                    % affsig(5) = aspect ratio
                                                                    % affsig(6) = skew angle
opt.tmplsize    = [32, 32];
sz              = opt.tmplsize;
thr_fst         = 0.9; 
thr_new         = 0.9;
n_sample        = opt.numsample;
param0          = [p(1), p(2), p(3)/sz(2), p(5), p(4)/p(3), 0];
param0          = affparam2mat(param0);
param           = [];
param.est       = param0';
numOfNegPatches = 600;
MaxSubClassNum  = 36;
category        = 2;
patchsize       = [6, 6];                                           % size of image blocks
num             = 71;

paramSR.lambda  = 0.01;
paramSR.lambda2 = 0;
paramSR.mode    = 2;

% --------- get gray image ----------------
pathForImg   = sprintf('./Images/%04d.jpg', 1);
img_color    = imread(pathForImg);
if size(img_color, 3) == 3
    grayImg = rgb2gray(img_color);
else
    grayImg = img_color;
end
grayImg = double(grayImg);

% --------- get negative image blocks -----
[dic_fst, nc_fst, v_fst, effNum_fst, ~] = updateDicSDA([], grayImg, param, opt.tmplsize, patchsize, category, MaxSubClassNum, numOfNegPatches);
dic_fst = real(dic_fst);
v_fst   = real(v_fst);
% -----------------------------------------

particlePatches = zeros(patchsize(1) * patchsize(2), nc_fst(1), n_sample);
upRate          = 5;
result          = zeros(num, 6);

% ---------------- loop for tracking --------------
for f = 1 : num
    
    % -------------- read image --------------------
    pathForImg   = sprintf('./Images/%04d.jpg', f);
    img_color    = imread(pathForImg);
    if size(img_color, 3) == 3
        grayImg = rgb2gray(img_color);
    else
        grayImg = img_color;
    end
    
    grayImg = double(grayImg);
    
    % ------------- template construction ----------
    if f == 1
        temppara   = affparam2geom(param.est(:));
        temppara   = affparam2mat(temppara);
        posImg     = warpimg(grayImg, temppara, sz);
        fstpatches = getPosImgBlocls(posImg, patchsize);
        fstP       = fstpatches ./ 255;
        
        pch            = v_fst(:, 1:effNum_fst)' * fstP;
        paramSR.L      = effNum_fst;
        paramSR.lambda = 0.01;
        alpha_fst      = mexLasso(pch, dic_fst, paramSR);
        alpha_fst      = full(alpha_fst);
    end
     
    % -------------- draw particles ----------------
    [wimgs, Y, param] = affineSample(grayImg, sz, opt, param);     % draw N candidates with particle filter                   

     % the weighted histogram for the template
    sim       = zeros(1, n_sample);
    for count = 1:n_sample
        particlePatches(:, :, count) = sampleFromImage(wimgs(:, :, count), patchsize);       % obtain M patches for each candidate
        particlePatches(:, :, count) = particlePatches(:, :, count) ./ 255;
        
        % get projection image
        paramSR.L   = effNum_fst;
        low_cor_fst = v_fst(:, 1:effNum_fst)' * particlePatches(:, :, count);
        alphaforfst = mexLasso(low_cor_fst, dic_fst, paramSR);
        alphaforfst = full(alphaforfst);
        recon_fst   = sum((low_cor_fst - dic_fst * alphaforfst).^2);
        
        if f <= upRate
           sim(count) = calSim(alphaforfst, alpha_fst, recon_fst);
        else
           paramSR.L   = effNum;
           low_cor     = v(:, 1:effNum)' * particlePatches(:, :, count);
           alpha4new   = mexLasso(low_cor, dic, paramSR);
           alpha4new   = full(alpha4new);
           recon_new   = sum((low_cor - dic * alpha4new).^2);
           
           [fstSim, occPerfst] = calSimWithDecOfOcc(alphaforfst, alpha_fst, recon_fst, thr_fst);
           [newSim, occPerNew] = calSimWithDecOfOcc(alpha4new, alpha_new, recon_new, thr_new);
           
           sim(count) = fstSim * occPerfst + newSim * occPerNew;
        end
     end
    
    % -------------- identify object image patch -------------
    [max_reco, maxidx] = max(sim); 
    param.est          = affparam2mat(param.param(:,maxidx));
    result(f,:)        = param.est';
    displayResult_sf;  
    
    % -------------- update dictionary -------------
    if mod(f, upRate) == 0    
        % fistr frame
        [dic_fst, nc_fst, v_fst, effNum_fst, posPatch_fst] = ...
        updateDicSDAWithPosSample(fstpatches, grayImg, param, opt.tmplsize, patchsize, category, MaxSubClassNum, numOfNegPatches);
        
        dic_fst        = real(dic_fst);
        v_fst          = real(v_fst);
        fstpch         = v_fst(:, 1:effNum_fst)' * (fstpatches ./ 255);
        paramSR.L      = effNum_fst;
        paramSR.lambda = 0.01;
        
        alpha_fst      = mexLasso(real(fstpch), dic_fst, paramSR);
        alpha_fst      = full(alpha_fst);
    
        % new frame
        [dic, nc, v, effNum, posPatch] = updateDicSDA([], grayImg, param, opt.tmplsize, patchsize, category, MaxSubClassNum, numOfNegPatches);
        
        dic            = real(dic);
        v              = real(v);
        pch            = v(:, 1:effNum)' * (posPatch ./ 255);
        paramSR.L      = effNum;
        paramSR.lambda = 0.01;
        
        alpha_new      = mexLasso(pch, dic, paramSR);
        alpha_new      = full(alpha_new);
    end
    % ----------------------------------------------
end