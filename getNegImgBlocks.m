function [patches] = getNegImgBlocks(img, param, originalSz, patchsize, numOfSamples)

n            = numOfSamples;    % Sampling Number

param0       = repmat(affparam2geom(param.est(:)), [1,n]);
randMatrix   = randn(6,n);
sigma        = [round(originalSz(2)) * 1.7, round(originalSz(1)) * 1.7, .00, param.est(4), .001, .000]; % 1.7
trackparam   = param0 + randMatrix .* repmat(sigma(:),[1,n]);

wback  = round(sigma(1));
wcenter = param0(1,1);
left    = wcenter - wback;
right   = wcenter + wback;

hback   = round(sigma(2));
hcenter = param0(2,1);
top     = hcenter - hback;
bottom  = hcenter + hback;

nono    = trackparam(1,:) <= right & trackparam(1,:)>= wcenter;
nono    = nono & (trackparam(2,:) >= top & trackparam(2,:) <= bottom);
trackparam(1,nono) = right;

nono    = trackparam(1,:) >= left & trackparam(1,:) < wcenter;
nono    = nono & (trackparam(2,:) >= top & trackparam(2,:) <= bottom);
trackparam(1,nono) = left;

% ---------------------------- test sampling --------------------------------------
% imageSize = [240 320];
% figure('position',[ 100 100 imageSize(2) imageSize(1) ]);
% set(gcf,'DoubleBuffer','on','MenuBar','none');
% axes(axes('position', [0 0 1.0 1.0]));
% imshow(uint8(img));
% numStr = sprintf('#%03d', 1);
% text(10,20,numStr,'Color','r', 'FontWeight','bold', 'FontSize',20);
% color = [ 0 1 0 ];
% for ii = 1:100
%     param0 = affparam2mat(trackparam(:, ii));
%     [center corners] = drawbox(patchsize, param0(:), 'Color', color, 'LineWidth', 2.5);
% end
% axis off;
% drawnow;
% -----------------------------------------------------------------------------

o        = affparam2mat(trackparam);
wimgs    = warpimg(img, o, patchsize);

m       = patchsize(1) * patchsize(2);             % vectorization
patches = zeros(m, n);
for i = 1:n
    patches(:,i) = reshape(wimgs(:,:,i), m, 1);
end