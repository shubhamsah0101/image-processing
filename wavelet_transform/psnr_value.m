clc; clear all; close all;

% Load Input Images
IR = imread('manWalkIR.jpg');
FuseImg = imread("fused_image_db2_dwt.jpg");

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
