% Assignment 1: Bonus Task

clear all;
close all;

%% read image
image = im2double(imread('../images/bonus.png'));

figure('name', 'unfiltered image');
imshow(image);
title('unfiltered image');

%% calculate FFT
% get shifted FFT of image
image_fft = fftshift(fft2(image));

% display the Fourier transform of the image
figure('name', 'unfiltered image FFT');
imshow(abs(image_fft), [0 1000]);
title('unfiltered image FFT');

%% generate bandstop filter

sigma_center = 15;
threshold_peaks = 1000;
sigma_peaks = 0.5;

min_y = -ceil(size(image_fft, 1) / 2 - 1);
max_y = floor(size(image_fft, 1) / 2);
min_x = -ceil(size(image_fft, 2) / 2 - 1);
max_x = floor(size(image_fft, 2) / 2);

[coords_x coords_y] = meshgrid(min_x:max_x, min_y:max_y);

% generate unnormalized kernel (maximum is 1) for highpass
kernel_center = 1 - exp(-(coords_x.^2 + coords_y.^2) / (2 * sigma_center^2));

% remove the center information to get the noise peaks
noise_fft = kernel_center .* image_fft;

% exactly locate the noise peaks
peaks = noise_fft > threshold_peaks;

% generate smooth notch filter by convolving peaks with unnormalized Gauss kernel
peaks_kernel_size = 4 * ceil(sigma_peaks) + 1;
peaks_kernel_radius = floor(peaks_kernel_size / 2);

[coords_x coords_y] = meshgrid(-peaks_kernel_radius:peaks_kernel_radius, -peaks_kernel_radius:peaks_kernel_radius);
kernel_peaks = exp(-(coords_x.^2 + coords_y.^2) / (2 * sigma_peaks^2));

% invert and add 1 to generate a filter where the noise is gaussian zeroed out
peak_filter = 1 - imfilter(double(peaks), kernel_peaks);

% multiply the image FFT with the notch filter to remove the noise
image_fft_denoised = image_fft .* peak_filter;

figure('name', 'filtered image FFT');
imshow(abs(image_fft_denoised), [0 1000]);
title('filtered image FFT');

% transform back to get denoised image
image_denoised = real(ifft2(ifftshift(image_fft_denoised)));

% calculate PSNR
image_original = im2double(rgb2gray(imread('../images/butterfly.jpg')));
psnr = task2_psnr(image_original, image_denoised);

disp(['denoised image PSNR is ' num2str(psnr) 'dB']);

figure('name', 'filtered image');
imshow(image_denoised);
title(['filtered image, PSNR=' num2str(psnr) 'dB']);
