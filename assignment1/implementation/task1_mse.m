function [mse] = task1_mse(image_original, image_modified, mask)
%TASK1_MSE calculate the MSE between 2 images
%   calculates the MSE between the 2 input images, ignoring new (black)
%   pixels given by mask

    size_y = size(image_original, 1);
    size_x = size(image_original, 2);
    
    if(size_y ~= size(image_modified, 1) || size_x ~= size(image_modified, 2) ...
        || size_y ~= size(mask, 1) || size_x ~= size(mask, 2))
        disp('ERROR: image and/or mask sizes do not match!');
        mse = inf;
        return;
    end
    
    % calculate squared error
    mse = (image_original - image_modified) .^ 2;
    
    % remove all new (black) pixels by setting their value = 0
    mse(mask) = 0;
    
    % calculate the sum over the squared error matrix
    mse = 1/(sum(mask(:))) * sum(mse(:));
    
end

