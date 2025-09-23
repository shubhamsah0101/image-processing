clc; clear all; close all;

% input infrared image
I = imread('imgIf.png');
imshow(I);
title('Original Image')

% input visual image

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

% Ensure uint8
maskedImage = im2uint8(maskedImage);

% Display result
figure;
subplot(1, 2, 1)
imshow(I)
title('Original Image')
subplot(1, 2, 2)
imshow(maskedImage)
title('Mask Image')

% Convert to double for calculations  
i_img = double(maskedImage);

% size of image
[m, n] = size(maskedImage);

% % % % % % % % % % % % % % % % % % % %
% Code block for Salient Target Mask  %
% % % % % % % % % % % % % % % % % % % %

% transformed image
stm = zeros(size(maskedImage));

for i = 1:m
    for j = 1:n
        if maskedImage(i,j) > 127
            stm(i,j) = 255;
        else
            stm(i,j) = 0;
        end
    end
end

% Convert back to uint8 for image display
% Salient Target Mask
stm = uint8(stm);

% figure;
% imshow(stm)
% title('Salient Target Mask')

% % % % % % % % % % % % % % % % % % % % 
% Code block for Background Mask      %
% % % % % % % % % % % % % % % % % % % %

% transformed image
bm = zeros(size(maskedImage));

for i = 1:m
    for j = 1:n
        if maskedImage(i,j) < 127
            bm(i,j) = 255;
        else
            bm(i,j) = 0;
        end
    end
end

% Salient Target Mask
bm = uint8(bm);

% figure;
% imshow(bm)
% title('Background Mask')

stm = double(rgb2gray(stm));
bm = double(rgb2gray(bm));
I = double(I);

result = stm .* I;
result = uint8(result);

figure;
imshow(result)