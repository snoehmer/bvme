% Assignment 2, Task 3: Feature Matching

close all;
clear all;

% paths
image_filename1 = '../images/match1.jpg';
image_filename2 = '../images/match2.jpg';

vlfeatroot = '/opt/vlfeat';

% Harris corner detector parameters
sigma = 0.5;
threshold = 0.05;

% initialize VLFeat toolbox
run([vlfeatroot '/toolbox/vl_setup']);
vl_version verbose;


%% read input image

image1 = im2double(rgb2gray(imread(image_filename1)));
image2 = im2double(rgb2gray(imread(image_filename2)));

%figure('name', 'input image');
%imshow(image);
%title('input image');


%% perform Harris corner detection

keypoints1 = harris(image1, sigma, threshold, true);

disp(['found ' num2str(size(keypoints1, 2)) ' keypoints in image1']);

keypoints2 = harris(image2, sigma, threshold, true);

disp(['found ' num2str(size(keypoints2, 2)) ' keypoints in image2']);


%% generate SIFT descriptors

descriptors1 = SIFTdescriptor(image1, keypoints1, true);

disp(['got ' num2str(size(descriptors1, 2)) ' descriptors in image1']);

descriptors2 = SIFTdescriptor(image2, keypoints2, true);

disp(['got ' num2str(size(descriptors2, 2)) ' descriptors in image2']);


%% perform matching

[kp_match1, kp_match2] = simple_matching(keypoints1, descriptors1, keypoints2, descriptors2);

disp(['found ' num2str(size(kp_match1, 2)) ' matches']);

% display results
display_matches(image1, kp_match1, image2, kp_match2);
