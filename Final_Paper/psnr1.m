clc; clear all; close all;

% Load Input Images
IR = imread('manWalkIR.jpg');
FuseImg = imread("std_result.jpg");
FuseImg = imresize(FuseImg, [300 300]);

IR = double(rgb2gray(IR));
FuseImg = double(rgb2gray(FuseImg));

[m, n] = size(FuseImg);

% rmse
for i = 1:m
    for j = 1:n
        value = (IR(i, j) - FuseImg(i, j)) .^ 2;
    end
end

result = sqrt(value ./ m*n);

% psnr

pmaxI = max(max(IR));
pmaxF = max(max(FuseImg));

ps = 10 * log10((pmaxF^2 - pmaxI^2) ./ result);





% clc; clear all; close all;

% Load Input Images
IR = imread('manWalkVB.jpg');
FuseImg = imread("std_result.jpg");

% Convert to grayscale and double
IR = double(rgb2gray(IR));
FuseImg = double(rgb2gray(FuseImg));

% Resize to match dimensions
[rows, cols] = size(IR);
FuseImg = imresize(FuseImg, [rows cols]);

% Compute Mean Squared Error (MSE)
mse_val = mean((IR(:) - FuseImg(:)).^2);

% Compute Root Mean Squared Error (RMSE)
rmse_val = sqrt(mse_val);

% Compute PSNR
MAX_I = 255;  % since image is double but originally 8-bit
psnr_val = 10 * log10((MAX_I^2) / mse_val);

% Display results
fprintf('RMSE = %.4f\n', rmse_val);
fprintf('PSNR = %.4f dB\n', psnr_val);
