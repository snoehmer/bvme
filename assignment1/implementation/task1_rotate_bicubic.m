function [image_out] = task1_rotate_bicubic(image_in, angle)
%TASK1_ROTATE_BICUBIC rotate image and perform bicubic interpolation
%   rotates the input image by angle degrees and performs bicubic interpolation

    image_out = zeros(size(image_in));
    
    size_y = size(image_in, 1);
    size_x = size(image_in, 2);

    % calculate coordinates of image center
    y_center = ceil(size_y / 2);
    x_center = ceil(size_x / 2);
    
    % calc minimum and maximum coordinates (with (0,0) at image center)
    y_min = 1 - y_center;
    y_max = y_min + size_y - 1;
    x_min = 1 - x_center;
    x_max = x_min + size_x - 1;
    
    % calc coordinates matrices for whole image (with (0,0) at image center)
    [x_coords, y_coords] = meshgrid(x_min:x_max, y_min:y_max);
    
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
            
            h_y = task1_h(diff_y);
            h_x = task1_h(diff_x);
            
            % multiply weights with pixels and sum up to get the output value
            weighted_input = image_in .* h_x .* h_y;
            
            image_out(y_out, x_out) = sum(weighted_input(:));
            
        end
        
    end
    
end

