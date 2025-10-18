clc; clear all; close all;

% Step 1: Read and preprocess the image
img = imread("final_result.jpg");  % Replace with your image
if size(img, 3) == 3
    img = rgb2gray(img);
end
img = double(img);  % Convert to double

% Step 2: Get image dimensions
[M, N] = size(img);

% Step 3: Compute RF (horizontal differences)
rf_sum = 0;
for i = 1:M
    for j = 2:N
        diff_val = img(i, j) - img(i, j-1);
        rf_sum = rf_sum + diff_val^2;
    end
end
RF = sqrt(rf_sum);

% Step 4: Compute CF (vertical differences)
cf_sum = 0;
for j = 1:N
    for i = 2:M
        diff_val = img(i, j) - img(i-1, j);
        cf_sum = cf_sum + diff_val^2;
    end
end
CF = sqrt(cf_sum);

% Step 5: Compute SF
SF = sqrt(RF^2 + CF^2);

% Step 6: Display result
fprintf('Spatial Frequency (SF): %.4f\n', SF);