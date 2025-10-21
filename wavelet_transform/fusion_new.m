clc; clear; close all;

% Load Input Images
IR = imread('manWalkIR.jpg');
VIS = imread('manWalkVB.jpg');
figure(1)
imshow(IR); title('Original Infrared Image');

% Preprocess Infrared Image
grayIR = rgb2gray(IR);
figure(2)
imhist(grayIR); title('Histogram of Infrared Grayscale Image');

smoothedIR = imgaussfilt(grayIR, 2);  % Gaussian smoothing
level = graythresh(smoothedIR);      % Otsu threshold
threshold = round(level * 255);
fprintf('Computed Otsu Threshold: %d\n', threshold);

binaryMask = smoothedIR > threshold;
binaryMask = imclose(binaryMask, strel('disk', 5));   % Fill gaps
binaryMask = bwareaopen(binaryMask, 100);             % Remove small fragments

% Apply Mask to IR Image
maskedIR = IR;
maskedIR(repmat(~binaryMask, [1 1 3])) = 0;
figure(3)
imshow(maskedIR); title('Masked IR Image (Auto ROI)');

% dwt of ir


% 4. Entropy
% Read the image
% img = imread("abc.jpg");
% imshow(img)
% 
% % Convert to grayscale if it's RGB
% if size(img, 3) == 3
%     img = rgb2gray(img);
% end
% 
% % Normalize image to [0, 1]
% img = double(img) / 255;
% 
% % Compute histogram
% numBins = 256;
% counts = imhist(img, numBins);
% probs = counts / sum(counts);
% 
% % Remove zero entries to avoid log(0)
% probs(probs == 0) = [];
% 
% % Compute entropy
% entropyValue = -sum(probs .* log2(probs));
% 
% % Display result
% fprintf('\n\nEntropy of the image: %.4f\n', entropyValue);
% 
% 
% % 5. Mutual Information :-
% % Compute MI for IR image
% MI_IR = computeMI(IR, "abc.jpg");
% 
% % Compute MI for VB image
% MI_VB = computeMI(VIS, "abc.jpg");
% 
% % Final MI sum
% MIFinal = MI_IR + MI_VB;
% 
% % Display results
% fprintf('\n\nMutual Information (IR vs Fused): %.4f\n', MI_IR);
% fprintf('Mutual Information (VB vs Fused): %.4f\n', MI_VB);
% fprintf('Combined Mutual Information: %.4f\n', MIFinal);