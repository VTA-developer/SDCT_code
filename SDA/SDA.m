function [v, L, rankB, K, D] = SDA(C, X, H, nh, thr)
%Subclass Discriminant Analysis.  

%input:
%C -- number of classes
%X -- n-by-p training data
%H -- 1-by-C matrix indicating the number of subclasses in one class
%nh -- 1-by-sum(H) matrix indicating the number of samples for each subclass
%thr -- since SigmaX maybe singular, we will eliminate the eigevectors of
%sigmax with eigenvalues less than sum(eigenvalue)/thr. the larger the
%rario, the more eigenvalue will be kept. 
%
%output:
%v -- the eigenvectors
%L -- number of PCs
%rankB -- rank of between subclass scatter matrix
%K -- conflicts value
%D -- Discriminant power


% --------  calculate SigmaX ---------
sampleData  = [];
for count = 1:C
    sampleData = [sampleData; X{count}];
end

numOfSample = size(sampleData, 1);
meanx       = mean(sampleData, 1);
temp        = sampleData - repmat(meanx, numOfSample, 1);
SigmaX      = temp'* temp ./ numOfSample;

[vx, dx]    = eig(SigmaX);
[dx,ind]    = sort(diag(dx)', 'descend');
vx          = vx(:,ind);
vx(: , dx < (sum(dx)/thr)) = [];
dx(dx < (sum(dx)/thr))   = [];
% -------------------------------------

% -------  calculate SigmaB -----------
numOfSubClass   = sum(H);
dim             = size(meanx , 2);
meansOfSubclass = zeros(numOfSubClass , dim);
probOfSubclass  = zeros(numOfSubClass , 1);

% get means of all subclasses
scount = 1;
for count = 1:C
    start = 0;
    for innercount = 1:H(count)
         meansOfSubclass(scount , :) = mean(X{count}((start + 1) : (start + nh{count}(innercount)), :) , 1);
         probOfSubclass(scount)      = nh{count}(innercount) / numOfSample;
         start = start + nh{count}(innercount);
         scount = scount + 1;
    end
end

SigmaB = zeros(dim , dim);
start  = 0;
for count = 1:(C - 1)
   for  innercount = 1:H(count)
       distOfMean = repmat(meansOfSubclass(start + innercount, :),numOfSubClass - start - H(count), 1) - ...
                    meansOfSubclass((H(count) + start + 1) : end, :);
       disposMean = distOfMean';
       for accMean = 1:(numOfSubClass - start - H(count))
            SigmaB = SigmaB + disposMean(:, accMean) * distOfMean(accMean , :) .* ...
                     probOfSubclass(start + innercount) .* ...
                     probOfSubclass(start + H(count) + accMean);
       end          
   end
   start = start + H(count);
end

opts.disp = 0;
rankB     = rank(SigmaB); 
[vb,db]   = eig(SigmaB);
db        = diag(db)';
[db,ind]  = sort(db, 'descend');
vb        = vb(:,ind);
% -------------------------------------

% -------------------------------------
L = length(dx); 
% reconstruct (inv(SigmaX)*SigmaB using selected eigens)
rat1    = db'*(1./dx);
rat2    = vb'* vx;
rat     = rat1 .* rat2; 
new_mtx = zeros(dim , dim);
for i=1:rankB
    tmpvx   = vx * rat(i,:)';
    new_mtx = new_mtx + tmpvx * vb(:,i)';    
end
[v , d]  = eig(new_mtx);
d        = diag(d)';
[d, ind] = sort(d, 'descend');
v       = v(:, ind);

%K.  value of conflicts -> the smaller the better. 
K = 0;
m = max(1,ceil(rankB / 2));  %m<rank(B)
for i = 1:m
    K = K + sum((vb(:,i)' * vx(:,1:min(i,L))).^2);    
end
K = K / m;

%D. Discriminant power --> the larger the better. 
mtx = rat2.^2;
mtx = rat1.*mtx;
D   = sum(sum(mtx));
D   = D/rankB; 
% -------------------------------------