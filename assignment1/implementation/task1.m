% Assignment 1, Task 1: Interpolation

close all;
clear all;

image_filename = 'test2.jpg';
rotation_steps = [-10, -10, 20];
max = 1;  % maximum value for a double-type image

%% read input image
image_original =  im2double(rgb2gray(imread(image_filename)));

figure(1);
imshow(image_original);

% calculate mask for ignored pixels (new pixels due to rotation)
mask = ones(size(image_original));

for i = 1:length(rotation_steps)
    mask = task1_rotate_bicubic(mask, rotation_steps(i));
end

mask = (abs(mask - 1) < 1e-3);


%% variant 1: nearest neighbor interpolation
image_nn = image_original;

for i = 1:length(rotation_steps)
    image_nn = task1_rotate_nn(image_nn, rotation_steps(i));
end

figure(2);
imshow(image_nn);

psnr_nn = 10 * log10(max^2 / task1_mse(image_original, image_nn, mask));
disp(['Nearest Neighbor Interpolation: PSNR = ' num2str(psnr_nn) 'dB']);


%% variant 2: bilinear interpolation
image_bilinear = image_original;

for i = 1:length(rotation_steps)
    image_bilinear = task1_rotate_bilinear(image_bilinear, rotation_steps(i));
end

figure(3);
imshow(image_bilinear);

psnr_bilinear = 10 * log10(max^2 / task1_mse(image_original, image_bilinear, mask));
disp(['Bilinear Interpolation: PSNR = ' num2str(psnr_bilinear) 'dB']);


%% variant 3: bicubic interpolation
image_bicubic = image_original;

for i = 1:length(rotation_steps)
    image_bicubic = task1_rotate_bicubic(image_bicubic, rotation_steps(i));
end

figure(4);
imshow(image_bicubic);

psnr_bicubic = 10 * log10(max^2 / task1_mse(image_original, image_bicubic, mask));
disp(['Bicubic Interpolation: PSNR = ' num2str(psnr_bicubic) 'dB']);
