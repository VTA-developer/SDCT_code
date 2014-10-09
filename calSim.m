function [sim] = calSim(alpha, cmpalpha, recon)

row = size(alpha , 1);
col = size(alpha , 2);

thr                = 0.8;                                  % the occlusion indicator  0.04          
thr_lable          = recon >= thr;   
temp               = ones(row, col);
temp(:, thr_lable) = 0;        
        
p                  = temp .* abs(alpha);                                       % the weighted histogram for the candidate
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