function [g] = task1_g(x)
%TASK1_G bilinear interpolation weights
%   this function calculates the pixel weights for bilinear interpolation

    g = zeros(size(x));
    
    L1 = abs(x) <= 1;
    L2 = abs(x) > 1;
    
    g(L1) = 1 - abs(x(L1));
    g(L2) = 0;

end

