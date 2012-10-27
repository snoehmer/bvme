function [h] = task1_h(x)
%TASK1_H bicubic interpolation weights
%   this function calculates the pixel weights for bicubic interpolation

    h = zeros(size(x));
    
    L1 = abs(x) <= 1;
    L2 = (abs(x) <= 2) & (abs(x) > 1);
    L3 = abs(x) > 2;
    
    h(L1) =  1.5 * abs(x(L1)).^3 - 2.5 * abs(x(L1)).^2 + 1;
    h(L2) = -0.5 * abs(x(L2)).^3 + 2.5 * abs(x(L2)).^2 - 4 * abs(x(L2)) + 2;
    h(L3) =  0;

end

