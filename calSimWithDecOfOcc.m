function [sim, occPer] = calSimWithDecOfOcc(alpha, cmpalpha, recon, occThr)

row = size(alpha , 1);
col = size(alpha , 2);

thr                = occThr;                                % the occlusion indicator        
thr_lable          = recon >= thr;   
temp               = ones(row, col);
temp(:, thr_lable) = 0;        
        
p                  = temp .* abs(alpha);                    % the weighted histogram for the candidate
p                  = reshape(p, 1, numel(p));
p                  = p./sum(p);
         
temp_qq               = ones(row, col);
temp_qq(:, thr_lable) = 0;
q                     = temp_qq .* abs(cmpalpha);     
q                     = reshape(q, 1, numel(q));
q                     = q./sum(q);
        
lambda_thr = 0.00003;                                       % the similarity between the candidate and the template
a          = sum(min([p; q]));
b          = lambda_thr * sum(thr_lable);
sim        = a + b;

occPer     = (size(recon , 2) - sum(thr_lable)) / (size(recon , 2) + eps);