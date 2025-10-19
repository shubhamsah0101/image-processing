clc; clear; close all;

% Step 1: Load Input Images
IR = imread('manWalkIR.jpg');
VIS = imread('manWalkVB.jpg');
figure, imshow(IR); title('Original Infrared Image');

% Step 2: Preprocess Infrared Image
grayIR = rgb2gray(IR);
figure, imhist(grayIR); title('Histogram of Infrared Grayscale Image');

smoothedIR = imgaussfilt(grayIR, 2);
level = graythresh(smoothedIR);
threshold = round(level * 255);
fprintf('Computed Otsu Threshold: %d\n', threshold);

binaryMask = smoothedIR > threshold;
binaryMask = imclose(binaryMask, strel('disk', 5));
binaryMask = bwareaopen(binaryMask, 100);

% Step 3: Apply Mask to IR Image
maskedIR = IR;
maskedIR(repmat(~binaryMask, [1 1 3])) = 0;
figure, imshow(maskedIR); title('Masked IR Image (Auto ROI)');

% Step 4: Create STM and BM Masks
stm = uint8(binaryMask) * 255;
bm = uint8(~binaryMask) * 255;

figure;
subplot(1,2,1); imshow(stm); title('Salient Target Mask');
subplot(1,2,2); imshow(bm); title('Background Mask');

greyI = rgb2gray(IR);
result1 = greyI .* uint8(binaryMask);
figure, imshow(result1); title('Salient × Infrared');

result2 = greyI .* uint8(~binaryMask);
figure, imshow(result2); title('Background × Infrared');

% Step 5: Visible Image Fusion
greyVIS = rgb2gray(VIS);
stmDouble = double(stm) / 255;
VIS_double = double(VIS);

Id = uint8(stmDouble .* double(greyVIS) + (1 - stmDouble) .* VIS_double);

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

% Step 6: Final Fusion
fusedFinal = uint8(0.5 * double(masked_rgb) + 0.5 * double(Id_rgb));
figure, imshow(fusedFinal); title('Final Fused Output (Auto ROI + Otsu)');

% Step 7: Simulated Convolutional Enhancement
conv1x1_1 = fusedFinal;
conv3x3 = imgaussfilt(conv1x1_1, 1);
conv1x1_2 = conv3x3;

convEnhanced = uint8(0.5 * double(fusedFinal) + 0.5 * double(conv1x1_2));
figure, imshow(convEnhanced); title('Simulated Convolutional Enhancement Output');