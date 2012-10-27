function [image_out] = task1_rotate_bilinear(image_in, angle)
%TASK1_ROTATE_BILINEAR rotate image and perform bilinear interpolation
%   rotates the input image by angle degrees and performs bilinear interpolation

    image_out = zeros(size(image_in));
    
    size_y = size(image_in, 1);
    size_x = size(image_in, 2);

    % prepare input image for correct border handling
    size_y_b = size(image_in, 1) + 2;
    size_x_b = size(image_in, 2) + 2;
    
    image_in_b = zeros(size_y_b, size_x_b);
    image_in_b(2:size_y_b-1, 2:size_x_b-1) = image_in(:,:);
    
    % calculate coordinates of image center
    y_center = ceil(size_y / 2);
    x_center = ceil(size_x / 2);
    
    y_center_b = ceil(size_y_b / 2);
    x_center_b = ceil(size_x_b / 2);
    
    % calc minimum and maximum coordinates (with (0,0) at image center)
    y_min_b = 1 - y_center_b;
    y_max_b = y_min_b + size_y_b - 1;
    x_min_b = 1 - x_center_b;
    x_max_b = x_min_b + size_x_b - 1;
    
    % calc coordinates matrices for whole image (with (0,0) at image center)
    [x_coords, y_coords] = meshgrid(x_min_b:x_max_b, y_min_b:y_max_b);
    
    for y_out = 1:size_y
        
        for x_out = 1:size_x
            
            % calculate coordinates with (0,0) at image center
            y_out_c = y_out - y_center;
            x_out_c = x_out - x_center;
            
            % perform transformation (rotation) on all pixels
            [y_in_c, x_in_c] = task1_transform(y_out_c, x_out_c, angle);
            
            % calculate weights for neighbor pixels
            diff_y = y_in_c - y_coords;
            diff_x = x_in_c - x_coords;
            
            g_y = task1_g(diff_y);
            g_x = task1_g(diff_x);
            
            % multiply weights with pixels and sum up to get the output value
            weighted_input = image_in_b .* g_x .* g_y;
            
            image_out(y_out, x_out) = sum(weighted_input(:));
            
        end
        
    end
    
end

