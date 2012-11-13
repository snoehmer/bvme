function [descriptors] = SIFTdescriptor(I, keypoints, verbose)
%SIFTDESCRIPTOR generates SIFT descriptors for image I and keypoints
%   keypoints is a 4xM matrix holding M keypoints
%   if verbose is true, the results are plotted

    region_factor = 3;
    sigma_w = 1.5;
    sigma_w2 = 2;
    
    W_patch = ceil(region_factor * sigma_w * 2);
    patch_size = 2 * W_patch + 1;
    
    main_orientation_bins = 36;
    
    W_descriptor = 2 * ceil(sqrt(2) * region_factor) + 1;
    patch_d_size = 2 * W_descriptor + 1;
    
    spatial_bins = 4;  % 4*4 spatial bins
    sample_orientation_bins = 8;
    
    descriptors = zeros(spatial_bins ^ 2 * sample_orientation_bins, size(keypoints, 2));
    
    descriptor_orientations = zeros(1, size(keypoints, 2));
   
    eigenval_scalefactor = 10;
    
    
    %% step 0: perform pre-calculations
    
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
    
    % calculate the Gaussian weights for main orientation detection
    weights_gauss = fspecial('gaussian', patch_size, sigma_w);
    
    % calculate the Gaussian weights for descriptor generation
    % sigma has to be region_factor * sigma_w2, because we still operate on
    % unnormalized coordinates!
    weights_gauss_d = fspecial('gaussian', patch_d_size, region_factor * sigma_w2);
    
    % assign limits for the 16 possible spatial bins
    spatial_bin_limits = -spatial_bins/2:spatial_bins/2;
    
    % assign limits for the 8 possible descriptor orientations
    orientation_values_d = linspace(0, 2*pi, sample_orientation_bins + 1);
    orientation_limits_d = [0, (orientation_values_d + (2 * pi / sample_orientation_bins)/2)];
    
    
    % calculate main orientation for each keypoint
    for i = 1:size(keypoints, 2)
   
        % keypoint coordinates
        y_kp = keypoints(2, i);
        x_kp = keypoints(1, i);
        
        
        %% step 1: crop the patch for processing
        
        % crop the patch around the keypoint
        y_start = max(1, y_kp - W_patch);
        y_end = min(size(I, 1), y_kp + W_patch);
        x_start = max(1, x_kp - W_patch);
        x_end = min(size(I, 2), x_kp + W_patch);
        
        patch_keypoint = I_angle(y_start:y_end, x_start:x_end);
        
        
        %% step 2: compute the main orientation of the patch
        
        % crop the weights to have the same matrix size
        y_start_w = W_patch - (y_kp - y_start) + 1;
        y_end_w = patch_size - (W_patch - (y_end - y_kp));
        x_start_w = W_patch - (x_kp - x_start) + 1;
        x_end_w = patch_size - (W_patch - (x_end - x_kp));
        
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
        
        descriptor_orientations(i) = main_orientation;
        
        
        %% step 3: construct descriptor
        
        % crop the patch around the keypoint
        y_start = max(1, y_kp - W_descriptor);
        y_end = min(size(I, 1), y_kp + W_descriptor);
        x_start = max(1, x_kp - W_descriptor);
        x_end = min(size(I, 2), x_kp + W_descriptor);
        
        patch_keypoint_a = I_angle(y_start:y_end, x_start:x_end);
        patch_keypoint_m = I_magnitude(y_start:y_end, x_start:x_end);
        
        % update the samples orientation to achieve rotation invariance
        patch_keypoint_a = patch_keypoint_a + main_orientation;
        
        % normalize the angles to [0°, 360°[
        patch_keypoint_a(patch_keypoint_a >= 2*pi) = ...
            patch_keypoint_a(patch_keypoint_a >= 2*pi) - 2*pi;
        
        % compute the sample orientations in the patch
        [~, sample_orientation] = histc(patch_keypoint_a, orientation_limits_d);
        
        % combine the half bins around 0°/360° (orientation 1 = last orientation)
        sample_orientation(sample_orientation == sample_orientation_bins + 1) = 1;
        
        
        % crop the weights to have the same matrix size
        y_start_w = W_descriptor - (y_kp - y_start) + 1;
        y_end_w = patch_d_size - (W_descriptor - (y_end - y_kp));
        x_start_w = W_descriptor - (x_kp - x_start) + 1;
        x_end_w = patch_d_size - (W_descriptor - (x_end - x_kp));
        
        % weight the gradient magnitude with the Gaussian weights
        patch_keypoint_m_w = patch_keypoint_m .* ...
            weights_gauss_d(y_start_w:y_end_w, x_start_w:x_end_w);
        
        
        % generate coordinates matrices of the patch
        [coords_x coords_y] = meshgrid(x_start:x_end, y_start:y_end);
        
        % calculate the coordinate displacement
        coords_x_d = coords_x - x_kp;
        coords_y_d = coords_y - y_kp;
        
        % now generate a coordinates vector to rotate the coordinates
        coords_d = [coords_y_d(:)'; coords_x_d(:)'];
        
        % perform the rotation
        coords_r = rot_mat(main_orientation) * coords_d;
        
        % normalize and adjust pixel center by -0.5
        coords_rn = 1 / region_factor * coords_r - 0.5;
        
        % generate original matrix from coordinates vector
        coords_y_rn = reshape(coords_rn(1,:), size(coords_y));
        coords_x_rn = reshape(coords_rn(2,:), size(coords_x));
        
        % generate a matrix indicating the corresponding bin
        [~, bin_id_y] = histc(coords_y_rn, spatial_bin_limits);
        [~, bin_id_x] = histc(coords_x_rn, spatial_bin_limits);
        
        bin_id = (bin_id_y - 1) * spatial_bins + bin_id_x;
        %bin_id = (bin_id_x - 1) * spatial_bins + bin_id_y;
        
        
        % generate a descriptor histogram for each bin
        descriptor_bins = zeros(spatial_bins^2, sample_orientation_bins);
        
        % calculate the descriptor for each spatial bin
        for current_sbin = 1:spatial_bins^2
            
            for current_bin = 1:sample_orientation_bins
                
                % logical index for samples in current spatial bin
                l1 = (bin_id == current_sbin);
                
                % logical index for samples with current orientation bin
                l2 = (sample_orientation == current_bin);
                
                % sum up all weighted magnitudes with same spatial bin and
                % same orientation bin
                % each row represents a spatial bin, the columns hold the histogram
                descriptor_bins(current_sbin, current_bin) = ...
                    sum(sum(patch_keypoint_m_w(l1 & l2)));
            
            end
            
        end
        
        
        % generate a feature vector from the matrix
        descriptor_vector = descriptor_bins';
        descriptor_vector = descriptor_vector(:);
        
        % normalize the feature vector to unit length
        descriptor_vector_n = 1/norm(descriptor_vector) * descriptor_vector;
        
        % clamp feature vector at 0.2
        descriptor_vector_n(descriptor_vector_n > 0.2) = 0.2;
        
        % re-normalize the feature vector to unit length
        descriptor_vector_n = 1/norm(descriptor_vector_n) * descriptor_vector_n;
        
        descriptors(:, i) = descriptor_vector_n;
        
    end
    
    
    if verbose
        
        % set the rotation to the correct orientation, not the eigenvector
        % corresponding to the smalles eigenvalue (90° shifted)
        keypoints_rot = keypoints;
        keypoints_rot(4,:) = descriptor_orientations;
        
        % scale the eigenvalue to increase the indicator size
        keypoints_scaled = keypoints_rot;
        keypoints_scaled(3,:) = keypoints_scaled(3,:) * eigenval_scalefactor;
        
        
        figure('name', 'SIFT descriptors');
        imshow(I);
        title('image with SIFT descriptors');
        hold on;
        vl_plotframe(keypoints_scaled);
        vl_plotsiftdescriptor(descriptors, keypoints_rot);
    end
    
end

