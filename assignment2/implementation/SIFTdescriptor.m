function [descriptors] = SIFTdescriptor(I, keypoints, verbose)
%SIFTDESCRIPTOR generates SIFT descriptors for image I and keypoints
%   keypoints is a 4xM matrix holding M keypoints
%   if verbose is true, the results are plotted

    region_factor = 3;
    sigma_w = 1.5;
    
    W_patch = ceil(region_factor * sigma_w * 2);
    patch_size = 2 * W_patch + 1;
    
    main_orientation_bins = 36;
   
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
    
    % convert to range [0°, 360°[
    I_angle(I_angle < 0) = I_angle(I_angle < 0) + 2 * pi;
    I_angle(I_angle == 2*pi) = 0;
    
    % assign limits for the 36 possible directions
    orientation_values = linspace(0, 2*pi, main_orientation_bins + 1);
    orientation_limits = [0, (orientation_values + (2 * pi / main_orientation_bins)/2)];
    
    % calculate the Gaussian weights
    weights_gauss = fspecial('gaussian', patch_size, sigma_w);
    
    % calculate main orientation for each keypoint
    for i = 1:size(keypoints, 2)
        
        % crop the patch around the keypoint
        y_start = max(1, keypoints(2, i) - W_patch);
        y_end = min(size(I, 1), keypoints(2, i) + W_patch);
        x_start = max(1, keypoints(1, i) - W_patch);
        x_end = min(size(I, 2), keypoints(1, i) + W_patch);
        
        patch_keypoint = I_angle(y_start:y_end, x_start:x_end);
        
        
        % crop the weights to have the same matrix size
        y_start_w = W_patch - (keypoints(2, i) - y_start) + 1;
        y_end_w = patch_size - (W_patch - (y_end - keypoints(2, i)));
        x_start_w = W_patch - (keypoints(1, i) - x_start) + 1;
        x_end_w = patch_size - (W_patch - (x_end - keypoints(1, i)));
        
        % weight the gradient magnitude with the Gaussian weights
        weights_patch = I_magnitude(y_start:y_end, x_start:x_end) .* ...
            weights_gauss(y_start_w:y_end_w, x_start_w:x_end_w);
        
        
        % compute the pricipal orientation of each patch orientation
        [~, patch_orientation] = histc(patch_keypoint, orientation_limits);
        
        % combine the half bins around 0°/360° (orientation 1 = last orientation)
        patch_orientation(patch_orientation == main_orientation_bins + 1) = 1;
        
        % generate a weighted histogram
        weighted_orientation_hist = zeros(1, main_orientation_bins);
        
        for current_orientation = 1:length(weighted_orientation_hist)
            
            weighted_orientation_hist(current_orientation) = ...
                sum(sum(weights_patch(patch_orientation == current_orientation)));
            
        end
        
        % find the maximum, this is the main orientation
        [~, main_orientation_index] = max(weighted_orientation_hist);
        
        main_orientation = orientation_values(main_orientation_index);
        
    end
    
end

