function [Fi, patch] = affineTrainL(img, patchsize, Fisize)
% function [Fi patch] = affineTrainL(dataPath, param0, opt, patchsize, patchnum, Fisize, forMat)
% obtain the dictionary for the SGM

% input --- 
% dataPath: the path for the input images
% param0: the initial affine parameters
% opt: initial parameters
% patchsize: the size of each patch
% patchnum: the number of patches in one candidate
% Fisize: the number of cluster centers
% forMat: the format of the input images in one video, for example '.jpg' '.bmp'.

% output ---
% Fi: the dictionary for the SGM
% patch: the patches obtained from the first frame (vector)

%*************************************************************
[height, width] = size(img);
patchnum(1)     = length(ceil(patchsize(1)/2) : (patchsize(1) / 2): floor(height - patchsize(1)/2));
patchnum(2)     = length(ceil(patchsize(2)/2) : (patchsize(2) / 2): floor(width  - patchsize(2)/2));

patch = zeros(prod(patchsize), prod(patchnum));

y           = patchsize(1)/2;
x           = patchsize(2)/2;
patch_centy = y : (patchsize(1) / 2): (height - y);
patch_centx = x : (patchsize(2) / 2): (width - x);
l =1;

% for j = 1: patchnum(1)                   % sliding window
%     for k = 1:patchnum(2)
%         data = image(patch_centy(j)-y+1 : patch_centy(j)+y, patch_centx(k)-x+1 : patch_centx(k)+x);
%         patch(:, l) = reshape(data,numel(data),1);
%         l = l+1;
%     end
% end

if mod(x, 2) == 0 & mod(y, 2) == 0 
    for j = 1: patchnum(1)                   % sliding window
        for k = 1:patchnum(2)
            data        = img((patch_centy(j) - y + 1) : (patch_centy(j) + y), (patch_centx(k)- x + 1) : (patch_centx(k) + x));    
            patch(:, l) = reshape(data, numel(data), 1);
            l           = l + 1;
        end
    end
else
    for j = 1: patchnum(1)                   % sliding window
        for k = 1:patchnum(2)
            data        = img(floor(patch_centy(j) - y + 1) : floor(patch_centy(j) + y), floor(patch_centx(k)- x + 1) : floor(patch_centx(k) + x));    
            patch(:, l) = reshape(data, numel(data), 1);
            l           = l + 1;
        end
    end
end

Fi = formCodebookL(patch, Fisize);      % form the dictionary