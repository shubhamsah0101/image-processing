clc; clear all; close all;

I = rgb2gray(imread('manWalkIR.jpg'));
imhist(I);
title('Histogram');
xlabel('Intensity Values');
ylabel('Pixel Count');

% Example manual threshold
T = 100;  
BW = I > T;

figure;
imshow(BW);
title(['Manual Threshold at ', num2str(T)]);