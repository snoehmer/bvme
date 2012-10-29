function [image_out] = task2_median(image_in, kernel_size)
%TASK2_MEDIAN perform median filtering with specified filter size
%   this function uses a little bit of matrix magic to speed up calculation 

    N_median = kernel_size * kernel_size;
    kernel_radius = floor(kernel_size / 2);
    
    % add a border by pixel replication
    image_in_b = task2_border(image_in, kernel_radius);
    
    % allocate memory for the median matrix
    % this matrix contains shifted versions of the original image
    magic = zeros(size(image_in, 1), size(image_in, 2), N_median);
    
    % calculate shifted images for fast median calculation
    for y = 1:kernel_size
        for x = 1:kernel_size
            min_y = y;
            max_y = size(image_in_b, 1) - kernel_size + y;
            min_x = x;
            max_x = size(image_in_b, 2) - kernel_size + x;
            
            magic(:,:,(y-1)*kernel_size + x) = image_in_b(min_y:max_y, min_x:max_x);
        end
    end
    
    median_matrix = median(magic, 3);
    
    image_out = squeeze(median_matrix);

end

