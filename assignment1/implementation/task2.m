% Assignment 1, Task2: Denoising

clear all;
close all;


%% load input images

image_butterfly_clean = im2double(rgb2gray(imread('../images/butterfly.jpg')));
image_butterfly = im2double(imread('../images/noise_butterfly.jpg'));

image_elephant_clean = im2double(rgb2gray(imread('../images/elephant.jpg')));
image_elephant = im2double(imread('../images/noise_elephant.jpg'));

image_gorilla_clean = im2double(rgb2gray(imread('../images/gorilla.jpg')));
image_gorilla = im2double(imread('../images/noise_gorilla.jpg'));



% -------------------------------------------------------------------------------------------------------------

%% butterfly + avg
avg_size = 3;

image_butterfly_avg = task2_filter(image_butterfly, 'avg', avg_size);
psnr_butterfly_avg = task2_psnr(image_butterfly_clean, image_butterfly_avg);
disp(['butterfly + avg filter: PSNR=' num2str(psnr_butterfly_avg) 'dB']);
figure('name', 'butterfly + avg');
imshow(image_butterfly_avg);
title(gca, ['Average Filter with Size = ' num2str(avg_size) ' gives PSNR=' num2str(psnr_butterfly_avg) 'dB']);

%% butterfly + gauss
gauss_sigma = 0.91;

image_butterfly_gauss = task2_filter(image_butterfly, 'gauss', gauss_sigma);
psnr_butterfly_gauss = task2_psnr(image_butterfly_clean, image_butterfly_gauss);
disp(['butterfly + Gauss filter: PSNR=' num2str(psnr_butterfly_gauss) 'dB']);
figure('name', 'butterfly + Gauss');
imshow(image_butterfly_gauss);
title(gca, ['Gauss Filter with Sigma = ' num2str(gauss_sigma) ' gives PSNR=' num2str(psnr_butterfly_gauss) 'dB']);

%% butterfly + median
median_size = 3;

image_butterfly_median = task2_filter(image_butterfly, 'median', median_size);
psnr_butterfly_median = task2_psnr(image_butterfly_clean, image_butterfly_median);
disp(['butterfly + median filter: PSNR=' num2str(psnr_butterfly_median) 'dB']);
figure('name', 'butterfly + median');
imshow(image_butterfly_median);
title(gca, ['Median Filter with Size = ' num2str(median_size) ' gives PSNR=' num2str(psnr_butterfly_median) 'dB']);



% -------------------------------------------------------------------------------------------------------------

%% elephant + avg
avg_size = 3;

image_elephant_avg = task2_filter(image_elephant, 'avg', avg_size);
psnr_elephant_avg = task2_psnr(image_elephant_clean, image_elephant_avg);
disp(['elephant + avg filter: PSNR=' num2str(psnr_elephant_avg) 'dB']);
figure('name', 'elephant + avg');
imshow(image_elephant_avg);
title(gca, ['Average Filter with Size = ' num2str(avg_size) ' gives PSNR=' num2str(psnr_elephant_avg) 'dB']);

%% elephant + gauss
gauss_sigma = 1.0;

image_elephant_gauss = task2_filter(image_elephant, 'gauss', gauss_sigma);
psnr_elephant_gauss = task2_psnr(image_elephant_clean, image_elephant_gauss);
disp(['elephant + Gauss filter: PSNR=' num2str(psnr_elephant_gauss) 'dB']);
figure('name', 'elephant + Gauss');
imshow(image_elephant_gauss);
title(gca, ['Gauss Filter with Sigma = ' num2str(gauss_sigma) ' gives PSNR=' num2str(psnr_elephant_gauss) 'dB']);

%% elephant + median
median_size = 3;

image_elephant_median = task2_filter(image_elephant, 'median', median_size);
psnr_elephant_median = task2_psnr(image_elephant_clean, image_elephant_median);
disp(['elephant + median filter: PSNR=' num2str(psnr_elephant_median) 'dB']);
figure('name', 'elephant + median');
imshow(image_elephant_median);
title(gca, ['Median Filter with Size = ' num2str(median_size) ' gives PSNR=' num2str(psnr_elephant_median) 'dB']);



% -------------------------------------------------------------------------------------------------------------

%% gorilla + avg
avg_size = 5;

image_gorilla_avg = task2_filter(image_gorilla, 'avg', avg_size);
psnr_gorilla_avg = task2_psnr(image_gorilla_clean, image_gorilla_avg);
disp(['gorilla + avg filter: PSNR=' num2str(psnr_gorilla_avg) 'dB']);
figure('name', 'gorilla + avg');
imshow(image_gorilla_avg);
title(gca, ['Average Filter with Size = ' num2str(avg_size) ' gives PSNR=' num2str(psnr_gorilla_avg) 'dB']);

%% gorilla + gauss
gauss_sigma = 1.19;

image_gorilla_gauss = task2_filter(image_gorilla, 'gauss', gauss_sigma);
psnr_gorilla_gauss = task2_psnr(image_gorilla_clean, image_gorilla_gauss);
disp(['gorilla + Gauss filter: PSNR=' num2str(psnr_gorilla_gauss) 'dB']);
figure('name', 'gorilla + Gauss');
imshow(image_gorilla_gauss);
title(gca, ['Gauss Filter with Sigma = ' num2str(gauss_sigma) ' gives PSNR=' num2str(psnr_gorilla_gauss) 'dB']);

%% gorilla + median
median_size = 5;

image_gorilla_median = task2_filter(image_gorilla, 'median', median_size);
psnr_gorilla_median = task2_psnr(image_gorilla_clean, image_gorilla_median);
disp(['gorilla + median filter: PSNR=' num2str(psnr_gorilla_median) 'dB']);
figure('name', 'gorilla + median');
imshow(image_gorilla_median);
title(gca, ['Median Filter with Size = ' num2str(median_size) ' gives PSNR=' num2str(psnr_gorilla_median) 'dB']);



% -------------------------------------------------------------------------------------------------------------

%% execution time analysis

% generate a big kernel to show performance difference
kernel_gauss = task2_gen_gauss(4);

% run convolution and measure execution time
tic;
image_gauss = task2_conv(image_gorilla_clean, kernel_gauss);
time_gauss = toc;

disp(['Homebrew Gauss filter execution time: ' num2str(time_gauss) 's']);


% run Matlab imfilter function
tic;
image_imfilter = imfilter(image_gorilla_clean, kernel_gauss);
time_imfilter = toc;

disp(['Matlab imfilter Gauss filter execution time: ' num2str(time_imfilter) 's']);
