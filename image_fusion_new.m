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

% Create STM and BM Masks
stm = uint8(binaryMask) * 255;
bm = uint8(~binaryMask) * 255;

figure(4)
subplot(1,2,1); imshow(stm); title('Salient Target Mask');
subplot(1,2,2); imshow(bm); title('Background Mask');

greyI = rgb2gray(IR);
result1 = greyI .* uint8(binaryMask);
figure(5)
imshow(result1); title('Salient × Infrared');

result2 = greyI .* uint8(~binaryMask);
figure(6)
imshow(result2); title('Background × Infrared');

% Visible Image Fusion
greyVIS = rgb2gray(VIS);
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

% Final Fusion
fusedFinal = uint8(0.5 * double(masked_rgb) + 0.5 * double(Id_rgb));
figure(7)
imshow(fusedFinal); title('Final Fused Output (Auto ROI + Otsu)');

% Simulated Convolutional Enhancement
conv1x1_1 = fusedFinal;                     % Simulated 1×1 conv
conv3x3 = imgaussfilt(conv1x1_1, 1);        % Simulated 3×3 conv
conv1x1_2 = conv3x3;                        % Simulated 1×1 conv

convEnhanced = uint8(0.5 * double(fusedFinal) + 0.5 * double(conv1x1_2));
figure(8)
imshow(convEnhanced); title('Simulated Convolutional Enhancement Output');

% Loss Function Evaluation
fusedGray = rgb2gray(convEnhanced);
refGray = rgb2gray(VIS);  % Reference can be VIS, IR, or maskedIR

% SSIM Loss
ssimVal = ssim(fusedGray, refGray);
L_ssim = 1 - ssimVal;

% Gradient Loss
Gx_fused = imgradient(fusedGray, 'sobel');
Gx_ref = imgradient(refGray, 'sobel');
L_grad = mean(abs(double(Gx_fused) - double(Gx_ref)), 'all') / 255;

% Total Loss
L_total = L_ssim + L_grad;

fprintf('\n--- Fusion Loss Evaluation ---\n');
fprintf('SSIM Loss      : %.4f\n', L_ssim);
fprintf('Gradient Loss  : %.4f\n', L_grad);
fprintf('Total Loss     : %.4f\n', L_total);