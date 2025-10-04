clc; clear all; close all;

% Load infrared and visible images
IR = imread('manWalkIR.jpg');
VIS = imread('manWalkIR_sharp.jpg');

% Display original IR image
figure;
imshow(IR);
title('Original Infrared Image');

% Convert IR image to grayscale
grayIR = rgb2gray(IR);

% Display histogram
figure;
imhist(grayIR);
title('Histogram of Infrared Grayscale Image');

% Apply Gaussian smoothing to reduce noise
smoothedIR = imgaussfilt(grayIR, 2);  % sigma = 2

% Compute Otsu threshold
level = graythresh(smoothedIR);         % returns normalized threshold [0,1]
threshold = round(level * 255);         % scale to [0,255]
fprintf('Computed Otsu Threshold: %d\n', threshold);

% Create binary mask using threshold
binaryMask = smoothedIR > threshold;

% Morphological closing to fill gaps
binaryMask = imclose(binaryMask, strel('disk', 5));  % fill small holes

% Remove small fragments
binaryMask = bwareaopen(binaryMask, 100);  % remove objects < 100 pixels

% Apply mask to IR image
maskedIR = IR;
maskedIR(repmat(~binaryMask, [1 1 3])) = 0;

% Display masked IR image
figure;
imshow(maskedIR);
title('Masked IR Image (Auto ROI)');

% Create Salient Target Mask (STM) and Background Mask (BM)
stm = uint8(binaryMask) * 255;
bm = uint8(~binaryMask) * 255;

% Display masks
figure;
subplot(1,2,1); imshow(stm); title('Salient Target Mask');
subplot(1,2,2); imshow(bm); title('Background Mask');

% Element-wise multiplication with IR image
greyI = rgb2gray(IR);
result1 = greyI .* uint8(binaryMask);
figure;
imshow(result1);
title('Salient × Infrared');

% Element-wise multiplication with background mask
result2 = greyI .* uint8(~binaryMask);
figure;
imshow(result2);
title('Background × Infrared');

% Prepare visible image
greyVIS = rgb2gray(VIS);

% Final fusion using masks
stmDouble = double(stm) / 255;
VIS_double = double(VIS);
Id = uint8(stmDouble .* double(greyVIS) + (1 - stmDouble) .* VIS_double);

% Ensure RGB format
if size(Id, 3) == 1
    Id_rgb = cat(3, Id, Id, Id);
else
    Id_rgb = Id;
end

if size(maskedIR, 3) == 1
    masked_rgb = cat(3, maskedIR, maskedIR, maskedIR);
else
    masked_rgb = maskedIR;
end

% Final weighted fusion
fusedFinal = uint8(0.5 * double(masked_rgb) + 0.5 * double(Id_rgb));

% Display final output
figure;
imshow(fusedFinal);
title('Final Fused Output (Auto ROI + Otsu)');