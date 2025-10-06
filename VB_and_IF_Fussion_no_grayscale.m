% WITHOUT CONVERTING TO GRAY SCALE

clc; clear all; close all;

% Load infrared and visible images
IR = imread("IR_meting012-1200_g.bmp");
VIS = imread("VIS_meting012-1200_r.bmp");

% Display original IR image
figure(1)
imshow(IR);
title('Original Infrared Image');

% Convert IR to grayscale only for thresholding (safe for both RGB or gray)
grayIR = im2gray(IR);  % ✅ replaces rgb2gray safely

% Display histogram
figure(2)
imhist(grayIR);
title('Histogram of Infrared Image (for thresholding only)');

% Apply Gaussian smoothing to reduce noise (on grayIR)
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
if size(IR,3) == 3
    maskedIR = IR;
    maskedIR(repmat(~binaryMask, [1 1 3])) = 0;
else
    maskedIR = IR;
    maskedIR(~binaryMask) = 0;
end

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

% Element-wise multiplication with IR image
if size(IR,3) == 3
    result1 = uint8(double(IR) .* repmat(binaryMask, [1 1 3]));
    result2 = uint8(double(IR) .* repmat(~binaryMask, [1 1 3]));
else
    result1 = uint8(double(IR) .* double(binaryMask));
    result2 = uint8(double(IR) .* double(~binaryMask));
end

figure(5)
imshow(result1);
title('Salient × Infrared');

figure(6)
imshow(result2);
title('Background × Infrared');

% Prepare visible image
VIS_double = double(VIS);
stmDouble = double(stm) / 255;

% Match mask dimensions to visible image
if size(VIS,3) == 3
    stmRGB = repmat(stmDouble, [1 1 3]);
else
    stmRGB = stmDouble;
end

% Fusion using mask
Id_rgb = uint8(stmRGB .* VIS_double + (1 - stmRGB) .* VIS_double);

% Weighted fusion
if size(maskedIR,3) == 3
    masked_rgb = maskedIR;
else
    masked_rgb = cat(3, maskedIR, maskedIR, maskedIR);
end

fusedFinal = uint8(0.5 * double(masked_rgb) + 0.5 * double(Id_rgb));

% Display final fused image
figure(7)
imshow(fusedFinal);
title('Final Fused Output (Auto ROI + Otsu)');

% Brighten
image = double(fusedFinal);
c = 1;
image_bright = c * log(1 + image);
image_bright = mat2gray(image_bright); % Normalize
figure(8)
imshow(image_bright);
title('Brighten');

% Denoise
image_denoise = imgaussfilt(image_bright, 1);
figure(9)
imshow(image_denoise);
title('Denoise');

% Sharpen
image_sharp = imsharpen(image_denoise, 'Radius', 2, 'Amount', 1);
figure(10)
imshow(image_sharp);
title('Sharp');
