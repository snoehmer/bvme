function [image_out] = task2_conv(image_in, kernel)
%TASK2_CONV convolves input image with filter kernel
%   this function convolves the input image with the filter kernel in a
%   simple and slow way

    if(size(kernel, 1) ~= size(kernel, 2))
        disp('ERROR: non-quadratic kernel used');
        image_out = 0;
        return;
    end
    
    if(mod(size(kernel, 1), 2) == 0)
        disp('ERROR: kernel must be odd-sized');
        image_out = 0;
        return;
    end
    
    size_y = size(image_in, 1);
    size_x = size(image_in, 2);
    
    kernel_size = size(kernel, 1);
    kernel_radius = floor(kernel_size / 2);
    
    image_out = zeros(size(image_in));
    
    
    % kernel must be flipped for convolution
    % all used kernels are symmetric, so this not really needed
    kernel_flipped = zeros(size(kernel));
    kernel_flipped(1:kernel_size, 1:kernel_size) = kernel(kernel_size:-1:1, kernel_size:-1:1);
    
    
    % add border to image
    image_in_b = task2_border(image_in, kernel_radius);
    
    % coordinates of original image within border
    min_y = 1 + kernel_radius;
    max_y = size(image_in_b, 1) - kernel_radius;
    min_x = 1 + kernel_radius;
    max_x = size(image_in_b, 2) - kernel_radius;
    
    
    % perform convolution for all image pixels
    for y = min_y:max_y
        
        for x = min_x:max_x
            
            patch_min_y = y - kernel_radius;
            patch_max_y = y + kernel_radius;
            patch_min_x = x - kernel_radius;
            patch_max_x = x + kernel_radius;
            
            y_out = y - kernel_radius;
            x_out = x - kernel_radius;
            
            % crop the corresponding image patch for multiplication with kernel
            patch = image_in_b(patch_min_y:patch_max_y, patch_min_x:patch_max_x);
            
            % perform convolution by multiplying patch with flipped kernel
            % and summing up the resulting matrix
            image_out(y_out, x_out) = sum(sum(patch .* kernel_flipped));
            
        end
        
    end

end

