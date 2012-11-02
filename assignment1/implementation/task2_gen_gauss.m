function [gauss_kernel] = task2_gen_gauss(sigma)
%TASK2_GEN_GAUSS generates a 2D Gauss kernel with specified sigma
%   the kernel size is generated to match the proper size

    kernel_size = 4 * ceil(sigma) + 1;
    kernel_radius = floor(kernel_size / 2);
    
    [coords_x, coords_y] = meshgrid(-kernel_radius:kernel_radius, -kernel_radius:kernel_radius);

    % generate the kernel
    gauss_kernel = exp(-(coords_x.^2 + coords_y.^2) ./ (2 * sigma^2));
    
    % normalize the kernel
    gauss_kernel = 1/sum(sum(gauss_kernel)) * gauss_kernel;

end

