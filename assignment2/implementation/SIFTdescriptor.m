function [descriptors] = SIFTdescriptor(I, keypoints, verbose)
%SIFTDESCRIPTOR generates SIFT descriptors for image I and keypoints
%   keypoints is a 4xM matrix holding M keypoints
%   if verbose is true, the results are plotted

    region_factor = 3;
    sigma_w = 1.5;
   
    plot_details = true;  % set this to true to plot results of each step
    
    
    %% step 1: estimate main orientation
    
    % calculate gradient magnitude and orientation
    kernel_sobel_y = fspecial('sobel');
    kernel_sobel_x = kernel_sobel_y';
    
    I_dx = imfilter(I, kernel_sobel_x, 'replicate', 'same', 'conv');
    I_dy = imfilter(I, kernel_sobel_y, 'replicate', 'same', 'conv');
    
    % calculate magnitude and angle of gradient
    I_magnitude = sqrt(I_dx .^ 2 + I_dy .^ 2);
    I_angle = atan2(I_dx, I_dy);  % swapped because origin is on top left
    
    % eliminate angles with magnitude = 0 (homogeneous areas)
    I_angle(I_magnitude == 0) = NaN;
    
    % correct angles by 90° (again because of origin on top left)
    I_angle = I_angle - pi/2;
    
    % convert to range [0°, 360°]
    
    
    
    
end

