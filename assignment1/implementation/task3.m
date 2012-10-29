% Assignment 1, Task 3: Canny Edge Detector

clear all;
close all;


%% common definitions

%image_filename = '../images/butterfly.jpg';
image_filename = 'testimage.png';

gauss_sigma = 0.5;

threshold_low = 0.3;
threshold_high = 0.7;


%% read image

image = im2double(rgb2gray(imread(image_filename)));


%% step 1: smooth image with Gaussian

gauss_kernel_size = 4 * ceil(gauss_sigma) + 1;
kernel_gauss = fspecial('gauss', [gauss_kernel_size gauss_kernel_size], gauss_sigma);

image_filtered = imfilter(image, kernel_gauss, 'replicate', 'conv');


%% step 2: calculate gradient with Sobel kernel

kernel_sobel_y = fspecial('sobel');
kernel_sobel_x = kernel_sobel_y';

dimage_x = imfilter(image, kernel_sobel_x, 'replicate', 'conv');
dimage_y = imfilter(image, kernel_sobel_y, 'replicate', 'conv');

% calculate magnitude and angle of gradient
image_magnitude = sqrt(dimage_x .^ 2 + dimage_y .^ 2);
image_angle = atan2(dimage_y, dimage_x);


%% step 3: perform non-maximum suppression

% find principal direction of edges
angle_limits = [-inf -7*pi/8:pi/4:7*pi/8 inf];

[~, angle_directions_full] = histc(image_angle, angle_limits);

% combine the same directions: 1=0°, 2=45°, 3=90°, 4=135°
angle_directions = angle_directions_full;
angle_directions(angle_directions_full == 5 | angle_directions_full == 9) = 1;
angle_directions(angle_directions_full == 6) = 2;
angle_directions(angle_directions_full == 7) = 3;
angle_directions(angle_directions_full == 8) = 4;

% generate image with replicated border
image_magnitude_b = task2_border(image_magnitude, 1);

% generate shifted matrices for non-maximum detection
image_magnitude_shifted_ul = image_magnitude_b(1:size(image_magnitude, 1),   1:size(image_magnitude, 2));
image_magnitude_shifted_u  = image_magnitude_b(1:size(image_magnitude, 1),   2:size(image_magnitude, 2)+1);
image_magnitude_shifted_ur = image_magnitude_b(1:size(image_magnitude, 1),   3:size(image_magnitude, 2)+2);
image_magnitude_shifted_l  = image_magnitude_b(2:size(image_magnitude, 1)+1, 1:size(image_magnitude, 2));
image_magnitude_shifted_r  = image_magnitude_b(2:size(image_magnitude, 1)+1, 3:size(image_magnitude, 2)+2);
image_magnitude_shifted_dl = image_magnitude_b(3:size(image_magnitude, 1)+2, 1:size(image_magnitude, 2));
image_magnitude_shifted_d  = image_magnitude_b(3:size(image_magnitude, 1)+2, 2:size(image_magnitude, 2)+1);
image_magnitude_shifted_dr = image_magnitude_b(3:size(image_magnitude, 1)+2, 3:size(image_magnitude, 2)+2);

% calculate 2 matrices with differences to correct neighbor pixels
image_magnitude_diff1 = zeros(size(image_magnitude));
image_magnitude_diff2 = zeros(size(image_magnitude));

image_magnitude_diff1(angle_directions == 1) = image_magnitude(angle_directions == 1) - image_magnitude_shifted_l(angle_directions == 1);
image_magnitude_diff2(angle_directions == 1) = image_magnitude(angle_directions == 1) - image_magnitude_shifted_r(angle_directions == 1);

image_magnitude_diff1(angle_directions == 2) = image_magnitude(angle_directions == 2) - image_magnitude_shifted_ur(angle_directions == 2);
image_magnitude_diff2(angle_directions == 2) = image_magnitude(angle_directions == 2) - image_magnitude_shifted_dl(angle_directions == 2);

image_magnitude_diff1(angle_directions == 3) = image_magnitude(angle_directions == 3) - image_magnitude_shifted_u(angle_directions == 3);
image_magnitude_diff2(angle_directions == 3) = image_magnitude(angle_directions == 3) - image_magnitude_shifted_d(angle_directions == 3);

image_magnitude_diff1(angle_directions == 4) = image_magnitude(angle_directions == 4) - image_magnitude_shifted_ul(angle_directions == 4);
image_magnitude_diff2(angle_directions == 4) = image_magnitude(angle_directions == 4) - image_magnitude_shifted_dr(angle_directions == 4);

% suppress all pixels which are not the maximum
image_nonmax = image_magnitude;

image_nonmax(image_magnitude_diff1 <= 0) = 0;
image_nonmax(image_magnitude_diff2 <= 0) = 0;


%% step 4: double thresholding

image_threshold = zeros(size(image_nonmax));

L1 = image_nonmax < threshold_low;
L2 = (image_nonmax >= threshold_low) & (image_nonmax < threshold_high);
L3 = image_nonmax >= threshold_high;

image_threshold(L1) = 0;
image_threshold(L2) = 0.6;
image_threshold(L3) = 1;


%% step 5: hysteresis

% iterate through the weak edges until there are no more changes
last_strong_edges = image_threshold == 1;

iteration = 1;

while 1
    
    % generate new strong edges matrix with 1 pixel border (0 valued)
    strong_edges_b = false(size(image_threshold, 1) + 2, size(image_threshold, 2) + 2);
    strong_edges_b(2:size(image_threshold, 1)+1, 2:size(image_threshold, 2)+1) = last_strong_edges;
    
    strong_edges_n = false(size(image_threshold));
    
    % generate new "8-neighborhood has strong edges" logical matrix
    strong_edges_n = ...
        strong_edges_b(1:size(strong_edges_n, 1),   1:size(strong_edges_n, 2))   | ...
        strong_edges_b(1:size(strong_edges_n, 1),   2:size(strong_edges_n, 2)+1) | ...
        strong_edges_b(1:size(strong_edges_n, 1),   3:size(strong_edges_n, 2)+2) | ...
        strong_edges_b(2:size(strong_edges_n, 1)+1, 1:size(strong_edges_n, 2))   | ...
        strong_edges_b(2:size(strong_edges_n, 1)+1, 3:size(strong_edges_n, 2)+2) | ...
        strong_edges_b(3:size(strong_edges_n, 1)+2, 1:size(strong_edges_n, 2))   | ...
        strong_edges_b(3:size(strong_edges_n, 1)+2, 2:size(strong_edges_n, 2)+1) | ...
        strong_edges_b(3:size(strong_edges_n, 1)+2, 3:size(strong_edges_n, 2)+2);
    
    strong_edges = last_strong_edges;
    
    % promote all weak edges with a strong edge in the 8-neighborhood to strong edges
    L1 = (image_threshold == 0.6) & strong_edges_n;
    
    strong_edges(L1) = true;

    % check if the iteration has terminated (no changes)
    if(strong_edges == last_strong_edges)
        break;
    end
    
    % else continue with the next iteration
    last_strong_edges = strong_edges;
    
    %figure('name', ['strong edges for iteration ' num2str(iteration)]);
    %imshow(strong_edges + image_threshold);
    
    iteration = iteration + 1;
end


disp(['binary edge detector image complete after ' num2str(iteration) ' iterations']);

% display binary strong edges matrix
figure('name', 'Canny Edge Detector result');
imshow(strong_edges);
title('Canny Edge Detector result');
