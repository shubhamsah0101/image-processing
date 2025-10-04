clc; clear all; close all;

% original image
image = imread("result_image1.jpg");
figure(1)
imshow(image)
title('Original Image')

% converting to gray scale
image = rgb2gray(image);
figure(2)
imshow(image)
title('Gray Scale')

% increase brightness
image = double(image);
c = 1;
image_bright = c * log(1 + image);
image_bright = mat2gray(image_bright); % Normalize
figure(3)
imshow(image_bright);
title('Brighten')

% denoise
% image_denoise = imgaussfilt(image_bright, 2);
% figure(4)
% imshow(image_denoise);
% title('Denoise')

% sharpen
image_sharp = imsharpen(image_bright, 'Radius', 2, 'Amount', 1);
figure(4)
imshow(image_sharp);
title('Sharp')