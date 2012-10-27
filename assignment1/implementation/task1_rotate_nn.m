function [image_out] = task1_rotate_nn(image_in, angle)
%TASK1_ROTATE_NN rotate image and perform nearest neighbor interpolation
%   rotates the input image by angle degrees and performs nn interpolation

    image_out = zeros(size(image_in));
    
    size_y = size(image_in, 1);
    size_x = size(image_in, 2);

    % calculate coordinates of image center
    y_center = ceil(size_y / 2);
    x_center = ceil(size_x / 2);
    
    for y_out = 1:size_y
        
        for x_out = 1:size_x
            
            % calculate coordinates with (0,0) at image center
            y_out_c = y_out - y_center;
            x_out_c = x_out - x_center;
            
            % perform transformation (rotation) on all pixels
            [y_in_c, x_in_c] = task1_transform(y_out_c, x_out_c, angle);
            
            % find nearest neighbor by rounding coordinates
            X_in_c = round([y_in_c, x_in_c]);
            
            % calculate image coordinates with (1,1) in upper left corner
            y_in = X_in_c(1) + y_center;
            x_in = X_in_c(2) + x_center;
            
            % copy pixels from input image to output image
            % but only if they are within the input image, otherwise set to 0
            if(y_in > 0 && y_in <= size_y && x_in > 0 && x_in <= size_x)
                image_out(y_out, x_out) = image_in(y_in, x_in);
            end
            
        end
        
    end

end

