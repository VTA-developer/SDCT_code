% function trackparam
% loads data and initializes variables

%*************************************************************
% 'title';
% the sequence to run.

% p = [px, py, sx, sy, theta];
% the location of the target in the first frame.
%
% px and py are the coordinates of the center of the box;
%
% sx and sy are the size of the box in the x (width) and y (height)
% dimensions, before rotation;
%
% theta is the rotation angle of the box;
%
% 'numsample';
% the number of samples used in the condensation algorithm/particle filter.
% Increasing this will likely improve the results, but make the tracker slower.
%
% 'affsig';
% these are the standard deviations of the dynamics distribution, and it controls the scale, size and area to
% sample the candidates.
%    affsig(1) = x translation (pixels, mean is 0)
%    affsig(2) = y translation (pixels, mean is 0)
%    affsig(3) = x & y scaling
%    affsig(4) = rotation angle
%    affsig(5) = aspect ratio
%    affsig(6) = skew angle
%
%*************************************************************

title   = 'Deer';
p       = [354, 38, 95, 65, 0];
opt     = struct('numsample',400, 'affsig',[16,20,.000,.000,.000,.000]);
thr_fst = 2; 
thr_new = 2;

