% Assignment 2, Task 2: SIFT

close all;
clear all;

% paths
image_filename = '../images/match2.jpg';

vlfeatroot = '/opt/vlfeat';

% Harris corner detector parameters
sigma = 0.5;
threshold = 0.1;

% initialize VLFeat toolbox
run([vlfeatroot '/toolbox/vl_setup']);
vl_version verbose;


%% read input image

image = im2double(rgb2gray(imread(image_filename)));

%figure('name', 'input image');
%imshow(image);
%title('input image');


%% perform Harris corner detection

keypoints = harris(image, sigma, threshold, true);

disp(['found ' num2str(size(keypoints, 2)) ' keypoints']);


%% generate SIFT descriptors

descriptors = SIFTdescriptor(image, keypoints, true);
