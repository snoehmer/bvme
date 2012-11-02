function [psnr] = task2_psnr(image1, image2)
%TASK2_PSNR calculates the PSNR of 2 images
%   this function assumes the images to be in double representation (max=1)

    % check if the images are the same, in the case PSNR is infinite
    if(image1 == image2)
        psnr = inf;
    end

    size_y = size(image1, 1);
    size_x = size(image1, 2);
    
    if(size_y ~= size(image2, 1) || size_x ~= size(image2, 2))
        disp('ERROR: image sizes do not match!');
        psnr = 0;
        return;
    end
    
    % calculate squared error
    mse = (image1 - image2) .^ 2;
    
    % calculate the sum over the squared error matrix
    mse = 1/(size_y * size_x) * sum(mse(:));

    % calculate PSNR
    psnr = 10 * log10(1 / mse);

end

