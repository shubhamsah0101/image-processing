clc; clear all; close all;

% input infrared image
IR = imread('manWalkIR.jpg');
imshow(IR);
title('Original Image')

% input visual image
VIS = imread('manWalkVB.jpg');
% imshow(VIS)
% title('Original Visual Image')

% Draw ROI interactively
h = drawfreehand;

% Create binary mask
mask = createMask(h);

% Apply mask to keep original size
if ndims(IR) == 3 % RGB
    maskedImage = IR;
    maskedImage(repmat(~mask, [1 1 3])) = 0; % background black
else % Grayscale
    maskedImage = IR;
    maskedImage(~mask) = 0;
end

% Display result
figure;
subplot(1, 2, 1)
imshow(IR)
title('Original Image')
subplot(1, 2, 2)
imshow(maskedImage)
title('Mask Image')

% Convert to gray scale for processing
grayImg = rgb2gray(maskedImage);

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
stmLogical = stm > 0;   % convert 255→1, 0→0

greyI = rgb2gray(IR);

result1 = greyI .* uint8(stmLogical);   % element-wise multiply

figure;
imshow(result1)
title('Salient Target mask X Infrared Image')

% element wise multiplication of background mask and visible image
bmLogic= bm > 0;

result2 = greyI .* uint8(bmLogic);

figure;
imshow(result2)
title('Background Mask X Visible Image')

% % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % 

% Loss Function

greyVIS = rgb2gray(VIS);

Id = (stm .* greyVIS) + ((1 - stm) .* VIS);
% thermal infrared target -> (stm .* greyVIS)
% backgroung region -> (1 - stm) .* VIS

figure;
imshow(Id)

% Ensure both images are RGB
if size(Id, 3) == 1
    Id_rgb = cat(3, Id, Id, Id);  % convert grayscale to RGB
else
    Id_rgb = Id;
end

if size(maskedImage, 3) == 1
    masked_rgb = cat(3, maskedImage, maskedImage, maskedImage);
else
    masked_rgb = maskedImage;
end

% Fuse using weighted average
fusedFinal = uint8(0.5 * double(masked_rgb) + 0.5 * double(Id_rgb));

% Display fused result
figure;
imshow(fusedFinal)
title('Fused Masked Image + Final Output')