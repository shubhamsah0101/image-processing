% Read Image
img1 = imread("thumb_print.tif");
figure(1)
imshow(img1)
title("Original Image")

% Apply Ideal High-Pass Filter
img2 = ideal_highpass_filter(img1, 30);
figure(2)
imshow(img2)
title("High-pass Filtered Image")

% Normalize the filtered image
img2_norm = mat2gray(img2);  % mat2gray() -> matrix to grey scale image

% Apply Thresholding using if-else
[m, n] = size(img2_norm);
binary_img = zeros(m, n);     

threshold = 0.5;              

for i = 1:m
    for j = 1:n
        if img2_norm(i, j) > threshold
            binary_img(i, j) = 1;
        else
            binary_img(i, j) = 0;
        end
    end
end

% Result
figure(3)
imshow(binary_img)
title('Binary Image')
