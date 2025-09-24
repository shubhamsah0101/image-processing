clc; clear all; close all;

% input infrared image
I = imread('manWalkIR.jpg');
imshow(I);
title('Original Image')

% Draw ROI interactively
h = drawfreehand;

% Create binary mask
mask = createMask(h);

% Apply mask to keep original size
if ndims(I) == 3 % RGB
    maskedImage = I;
    maskedImage(repmat(~mask, [1 1 3])) = 0; % background black
else % Grayscale
    maskedImage = I;
    maskedImage(~mask) = 0;
end

% Display result
figure;
subplot(1, 2, 1)
imshow(I)
title('Original Image')
subplot(1, 2, 2)
imshow(maskedImage)
title('Mask Image')

% Convert to gray scale for processing
if ndims(maskedImage) == 3
    grayImg = rgb2gray(maskedImage);
else
    grayImg = maskedImage;
end

% % % % % % % % % % % % % % % % % % % %
% Code block for Salient Target Mask  %
% % % % % % % % % % % % % % % % % % % %

threshold = 80;
stm = uint8(grayImg > threshold) * 255;

figure;
imshow(stm)
title('Salient Target Mask')

% % % % % % % % % % % % % % % % % % % % 
% Code block for Background Mask      %
% % % % % % % % % % % % % % % % % % % %

% transformed image
bm = uint8(grayImg < threshold) * 255;

figure;
imshow(bm)
title('Background Mask')

% element wise multiplication of sailent mask and infrared image

% ---------- Apply STM to Original Image (direct multiplication) ----------
stmLogical = stm > 0;   % convert 255→1, 0→0

% if ndims(I) == 3
%     % For RGB image, replicate mask across 3 channels
%     stmLogical = repmat(stmLogical, [1 1 3]);
% end

greyI = rgb2gray(I);

result = greyI .* uint8(stmLogical);   % element-wise multiply

figure;
imshow(result)
title('Salient Target Region (Direct Multiplication)')


% figure;
% imshow(result)
% title('Salient Target mask X Infrared Image')