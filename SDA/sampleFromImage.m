function [patch] = sampleFromImage(img, patchsize)

if size(img, 3) == 3
    img	= double(rgb2gray(img));
else
    img	= double(img);
end

%img = cropImage(img, 0, 30);

[height, width] = size(img);
patchnum(1)     = length(ceil(patchsize(1)/2) : (patchsize(1) / 2): floor(height - patchsize(1)/2));
patchnum(2)     = length(ceil(patchsize(2)/2) : (patchsize(2) / 2): floor(width  - patchsize(2)/2));

patch     = zeros(prod(patchsize), prod(patchnum));

y         = patchsize(1)/2;
x         = patchsize(2)/2;

patch_centy = y : (patchsize(1) / 2): (height - y);
patch_centx = x : (patchsize(2) / 2): (width - x);
l           = 1;

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