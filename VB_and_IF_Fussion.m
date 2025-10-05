% Purpose : Fusion of Visible Image and Infrared Image.

clc; clear all; close all;

% ----- Step - 1 : Creating Salient and Background Mask ----- %

% Load infrared and visible images
IR = imread('manWalkIR.jpg');
VIS = imread('manWalkVB.jpg');

% Display original IR image
figure(1)
imshow(IR);
title('Original Infrared Image');

% Convert IR and VB image to grayscale
grayIR = rgb2gray(IR);
grayVB = rgb2gray(VIS);

% Display histogram for Infrared Image
figure(2)
imhist(grayIR);
title('Histogram of Infrared Grayscale Image');

% Compute Otsu threshold
level = graythresh(grayIR);         % returns normalized threshold [0,1]
threshold = round(level * 255);     % scale to [0,255]
fprintf('Computed Otsu Threshold: %d\n', threshold);

% Create binary mask using threshold
binaryMask = grayIR > threshold;

% Apply mask to IR image
maskedIR = IR;
maskedIR(repmat(~binaryMask, [1 1 3])) = 0;

% Display masked IR image
figure(3)
imshow(maskedIR);
title('Masked IR Image (Auto ROI)');

% Create Salient Target Mask (STM) and Background Mask (BM)
stm = uint8(binaryMask) * 255;
bm = uint8(~binaryMask) * 255;

% Display masks
figure(4)
subplot(1,2,1); imshow(stm); title('Salient Target Mask');
subplot(1,2,2); imshow(bm); title('Background Mask');

% ----- Step - 2 : Fusion of both the Masks ----- %

% Element-wise multiplication with IR image
% greyI = rgb2gray(IR);
result1 = grayIR .* uint8(stm);
figure(5)
imshow(result1);
title('Salient × Infrared');

% Element-wise multiplication with background mask
result2 = grayVB .* uint8(bm);
figure(6)
imshow(result2);
title('Background × Visible');

% Final fusion using masks
stmDouble = double(stm) / 255;
VIS_double = double(grayVB);
Id = uint8(stmDouble .* double(grayVB) + (1 - stmDouble) .* VIS_double);

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
figure(7)
imshow(fusedFinal);
title('Final Fused Output (Auto ROI + Otsu)');

% ----- Step - 3 : Increasing the broghtness of Final Image ----- %

% converting to gray scale
image = rgb2gray(fusedFinal);
figure(8)
imshow(image)
title('Gray Scale')

% increase brightness
image = double(image);
c = 1;
image_bright = c * log(1 + image);
image_bright = mat2gray(image_bright); % Normalize
figure(9)
imshow(image_bright);
title('Brighten')

% denoise
% image_denoise = imgaussfilt(image_bright, 2);
% figure(4)
% imshow(image_denoise);
% title('Denoise')

% sharpen
image_sharp = imsharpen(image_bright, 'Radius', 2, 'Amount', 1);
figure(10)
imshow(image_sharp);
title('Sharp')