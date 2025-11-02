clc;clear all;close all;

infra_image = imread("manWalkIR.jpg");
fused_image = imread("std_with_dwt_result.jpg");  % dwt only
% fused_image = imread("wavelet_std_result.jpg");   % dwt with STDFusionNet

infra_gray = rgb2gray(infra_image);
fused_gray = rgb2gray(fused_image);

[m, n] = size(infra_gray);

for i = 1:m
    for j = 1:n
        value = abs(double(infra_gray(i, j)) - double(fused_gray(i, j))) ./ double(infra_gray(i, j));
    end
end

final = (1 / (m*n)) * value;

fprintf('Deviation : %e\n', final)