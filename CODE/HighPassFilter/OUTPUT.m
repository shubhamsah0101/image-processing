% original Image
% img = imread("moon.tif");
% figure(1)
% imshow(img)
% title("Original Image")
% 
% % 1. Laplacian Filter
% figure(2)
% imshow(Laplacian(img))
% title("After applying Laplacian Filter")
% 
% % 2. Unsharp Mask and Highboost Filter
% figure(3)
% imshow(UnSharpMask(img, 5))
% title("After applying Unsharp Mask")

% 3. Sobel Operator
img = imread("lens.tif");
figure(1)
imshow(img)
title("Original Image")

figure(2)
imshow(Sobel(img))
title("After applying Sobel Operator")
