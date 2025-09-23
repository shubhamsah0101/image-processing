clc; clear all; close all;

% original image
img = imread("skeleton.tif");
img_dou = double(img);
figure(1)
imshow(img)
title("Original Image")

% laplacian image
lap = Laplacian(img_dou);
figure(2)
imshow(lap)
title("Laplacian")

% original + laplacian
lap_dou = double(lap);
add = img_dou + lap_dou;
add = max(0, min(add, 255));
% Convert to uint8
add = uint8(add);
figure(3)
imshow(add)
title("Original + Laplacian")

% sobel gradient of original image
sobel_img = Sobel(img);
figure(4)
imshow(sobel_img)
title("Sobel Gradient")

% smoothing sobel image with 5x5 box filter
img2 = Box(sobel_img, 5);
figure(5)
imshow(img2)
title("5x5 Box Filter")

% creating mask from product of laplacian and 5x5 box filter images
m = zeros(800, 500);
m(3:end-2, 3:end-2) = img2;

% img2_dou = double(m);
% mask = lap_dou .* m;
% % Convert to uint8
% mask = uint8(mask);
figure(6)
imshow(m)
title("Mask")