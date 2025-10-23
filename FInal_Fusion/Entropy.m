% script to compute image entropy (EN)

clc;clear all; close all;

% Step 1: Read the image
img = imread("result_new.jpg");  % Replace with your image file
% imshow(img)

% Step 2: Convert to grayscale if it's RGB
if size(img, 3) == 3
    img = rgb2gray(img);
end

% Step 3: Normalize image to [0, 1]
img = double(img) / 255;

% Step 4: Compute histogram
numBins = 256;
counts = imhist(img, numBins);
probs = counts / sum(counts);

% Step 5: Remove zero entries to avoid log(0)
probs(probs == 0) = [];

% Step 6: Compute entropy
entropyValue = -sum(probs .* log2(probs));

% Step 7: Display result
fprintf('Entropy of the image: %.4f\n', entropyValue);