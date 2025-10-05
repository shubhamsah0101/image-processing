clc; clear all; close all;

% final image
image = imread('final_result.jpg');
figure(1)
imshow(image)
title('Final Image')

% histogram of final image
pl = imhist(image);

% number of gray levels
L = length(pl);

for i = 1:length(L)
    result = (pl(i) * log2(pl(i)));
end

% entropy
en = -result;