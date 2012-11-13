function [keypoints] = harris(I, sigma, thresh, verbose)
%HARRIS performs Harris corner detection on the image I
%   sigma is the parameter for the Gaussian kernel
%   thresh is the parameter for corner strength thresholding
%   verbose enables image output if true

    k = 0.04;  % Harris k parameter
    eigenval_scalefactor = 10;  % scales the eigenvalues for visibility
    plot_details = false;  % set this to true to plot results of each step

    
    %% step 1: calculate gradients using Sobel
    
    kernel_sobel_y = fspecial('sobel');
    kernel_sobel_x = kernel_sobel_y';
    
    I_x = imfilter(I, kernel_sobel_x, 'replicate', 'same', 'conv');
    I_y = imfilter(I, kernel_sobel_y, 'replicate', 'same', 'conv');
    
    if plot_details
        figure('name', 'Sobel results');
        subplot(1, 2, 1);
        imshow(I_x, []);
        title('I_x');
        subplot(1, 2, 2);
        imshow(I_y, []);
        title('I_y');
    end
    
    
    %% step 2: calculate structure tensor
    
    I_x2 = I_x .^ 2;
    I_y2 = I_y .^ 2;
    I_xy = I_x .* I_y;
    
    if plot_details
        figure('name', 'structure tensor');
        subplot(1, 3, 1);
        imshow(I_x2, []);
        title('I_x2');
        subplot(1, 3, 2);
        imshow(I_y2, []);
        title('I_y2');
        subplot(1, 3, 3);
        imshow(I_xy, []);
        title('I_xy');
    end
    
    
    %% step 3: perform Gaussian filtering
    
    kernel_gauss = fspecial('gaussian', 4 * ceil(sigma) + 1, sigma);
    
    G_x2 = imfilter(I_x2, kernel_gauss, 'replicate', 'same', 'conv');
    G_y2 = imfilter(I_y2, kernel_gauss, 'replicate', 'same', 'conv');
    G_xy = imfilter(I_xy, kernel_gauss, 'replicate', 'same', 'conv');
    
    if plot_details
        figure('name', 'Gaussian results');
        subplot(1, 3, 1);
        imshow(G_x2, []);
        title('G_x2');
        subplot(1, 3, 2);
        imshow(G_y2, []);
        title('G_y2');
        subplot(1, 3, 3);
        imshow(G_xy, []);
        title('G_xy');
    end

    
    %% step 4: calculate Harris corner response
    
    det_A = G_x2 .* G_y2 - G_xy .^ 2;
    trace_A = G_x2 + G_y2;
    
    HCR = det_A - k * trace_A .^ 2;
    
    if plot_details
        figure('name', 'HCR');
        imshow(HCR, []);
    end
    
    
    %% step 5: thresholding
    
    HCR_threshold = HCR;
    HCR_threshold(HCR < thresh) = 0;
    
    if plot_details
        figure('name', 'HCR_threshold');
        imshow(HCR_threshold, []);
    end
    
    
    %% step 6: non-maxiumum suppression
    
    nm_radius = 2;  % defines the radius for non-maximum suppression (=5x5)
    
    HCR_nonmax = HCR_threshold;
    
    % generate coordinates
    [pos_x pos_y] = meshgrid(1:size(HCR_nonmax, 2), 1:size(HCR_nonmax, 1));
    
    
    % perform non-maximum suppression around maximum values
    i = 1;
    
    while true
        
        % vectorize current HCR and coordinates
        HCR_v = HCR_nonmax(:);
        pos_x_v = pos_x(:);
        pos_y_v = pos_y(:);

        % remove 'zero' elements
        L_nonzero = (HCR_v > 0);
        HCR_v = HCR_v(L_nonzero);
        pos_x_v = pos_x_v(L_nonzero);
        pos_y_v = pos_y_v(L_nonzero);

        % sort HCR vector and get indices
        [HCR_v_sorted, indices] = sort(HCR_v, 'descend');

        % calculate positions of sorted HCR values
        pos_x_v_sorted = pos_x_v(indices);
        pos_y_v_sorted = pos_y_v(indices);

        
        % stop calculation if all nonzero values are finished
        if i > length(HCR_v_sorted)
            break;
        end
    
        
        % calculate boundaries for the neighborhood
        y_start = max(1, pos_y_v_sorted(i) - nm_radius);
        y_end = min(size(HCR_nonmax, 1), pos_y_v_sorted(i) + nm_radius);
        x_start = max(1, pos_x_v_sorted(i) - nm_radius);
        x_end = min(size(HCR_nonmax, 2), pos_x_v_sorted(i) + nm_radius);
        
        % logical mask 1 masks the neighborhood
        L1 = false(size(HCR_nonmax));
        L1(y_start:y_end, x_start:x_end) = true;
        L1(pos_y_v_sorted(i), pos_x_v_sorted(i)) = false;
        
        % logical mask 2 masks the values that are smaller than the current value
        L2 = (HCR_nonmax <= HCR_v_sorted(i));
        
        % logical mask for non-maximum suppression in neighborhood is l1 AND l2
        L = L1 & L2;
        
        HCR_nonmax(L) = 0;
        
        i = i + 1;
        
    end
    
    
    if plot_details
        figure('name', 'HCR_nonmax');
        imshow(HCR_nonmax, []);
    end
    
    
    %% step 7: generate keypoints matrix
    
    % vectorize HCR matrix
    HCR_v = HCR_nonmax(:);
    pos_x_v = pos_x(:);
    pos_y_v = pos_y(:);
    
    % remove 'zero' elements
    L_nonzero = (HCR_v > 0);
    HCR_v = HCR_v(L_nonzero);
    pos_x_v = pos_x_v(L_nonzero);
    pos_y_v = pos_y_v(L_nonzero);
    
    % sort HCR vector and get indices
    [HCR_v_sorted, indices] = sort(HCR_v, 'descend');
    
    % calculate positions of sorted HCR values
    pos_x_v_sorted = pos_x_v(indices);
    pos_y_v_sorted = pos_y_v(indices);
    
    
    % calculate eigenvalue magnitude and eigenvector orientation
    eigenvalues = zeros(size(HCR_v_sorted));
    eigenvector_orientations = zeros(size(HCR_v_sorted));
    
    for i = 1:length(HCR_v_sorted)
        
        % build A matrix
        A = [G_x2(pos_y_v_sorted(i), pos_x_v_sorted(i)) G_xy(pos_y_v_sorted(i), pos_x_v_sorted(i)); ...
             G_xy(pos_y_v_sorted(i), pos_x_v_sorted(i)) G_y2(pos_y_v_sorted(i), pos_x_v_sorted(i))];
        
        % calculate eigenvalues and eigenvectors
        [V, D] = eig(A);
        
        % select smallest eigenvalue
        [eigenval, eigenvect_pos] = min(diag(D));
        
        % select corresponding eigenvector
        eigenvect = V(:, eigenvect_pos);
        
        % calculate magnitude of smallest eigenvalue
        eigenvalues(i) = abs(eigenval);
        
        % calculate eigenvector orientation
        eigenvector_orientations(i) = atan2(eigenvect(1), eigenvect(2));
        
    end
    
    
    % build keypoints matrix
    keypoints = zeros(4, length(HCR_v_sorted));
    
    keypoints(1, :) = pos_x_v_sorted;
    keypoints(2, :) = pos_y_v_sorted;
    keypoints(3, :) = eigenvalues;
    keypoints(4, :) = eigenvector_orientations;
    
    
    %% step 8: display image with detected corners
    
    if verbose
        
        % scale the eigenvalue to increase the indicator size
        keypoints_scaled = keypoints;
        keypoints_scaled(3,:) = keypoints_scaled(3,:) * eigenval_scalefactor;
    
        figure('name', 'image with detected corners');
        imshow(I);
        hold on;
        vl_plotframe(keypoints_scaled);
        title('image with detected corners');
    end
    
end

