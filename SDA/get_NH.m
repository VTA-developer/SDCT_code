function NH = getNH(category, H, nc)
%function: get the number of each subclass according the the given input
%
%input:
%category: number of classes 
%H: category-by-1 matrix, indicating the number of subclasses for each class
%nc: category-by-1 matrix, indicationg the number of samples for each class;
%
%output:
%NH: sum(H)-by-1 matrix, indicating the number of samples in each subclass
%
%

NH = cell(1, category);
for i = 1:category
    tempNH = []; 
    if mod(nc(i),H(i)) == 0
        nh = nc(i) / H(i);
        for j = 1:H(i)
            tempNH = [tempNH, nh];   
        end
    else
        nh = fix(nc(i)/H(i));
        if (mod(H(i),2)~=0)  % H(i) is odd
            for j=1:(H(i)-1)/2
                tempNH = [nh,tempNH,nh];    
            end
            tempNH = [tempNH(1:j), nc(i) - nh * 2 * j, tempNH(j + 1:end)];
        else
            for j=1:(H(i)-2)/2    %H(i) is even
                tempNH = [nh,tempNH,nh];    
            end
            if (H(i) == 2) j = 0; end;
            tempNH=[tempNH(1:j),nh,nc(i)-nh*(2*j+1),tempNH(j+1:end)];
        end
     end
     NH{i} = tempNH;
end