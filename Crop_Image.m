clc; clear all; close all;

% Import image
I = imread('imgIf.png'); % Change filename as needed
imshow(I);

% Draw ROI interactively
h = drawfreehand; % Or drawrectangle, drawellipse, etc.

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
subplot(1, 2, 2)
imshow(maskedImage)