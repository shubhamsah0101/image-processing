clc; clear all; close all;

img = imread("std_with_dwt_result.jpg");
if size(img, 3) == 3
    img = rgb2gray(img);
end
img = double(img) / 255;  % Normalize to [0, 1]
[M, N] = size(img);

rf_sum = 0;
for i = 1:M
    for j = 2:N
        diff_val = img(i, j) - img(i, j-1);
        rf_sum = rf_sum + diff_val^2;
    end
end
RF = sqrt(rf_sum / (M * N));

cf_sum = 0;
for j = 1:N
    for i = 2:M
        diff_val = img(i, j) - img(i-1, j);
        cf_sum = cf_sum + diff_val^2;
    end
end
CF = sqrt(cf_sum / (M * N));

SF = sqrt(RF^2 + CF^2);

fprintf('Spatial Frequency (SF): %.4f \n', SF);