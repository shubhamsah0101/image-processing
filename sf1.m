clc;
clear;

% Step 1: Read the image
% [filename, pathname] = uigetfile({'.jpg;.png;*.bmp','Image Files'}, 'Select an Image');
% if isequal(filename,0)
%     error('No image selected.');
% end
img = imread("final_result.jpg");

% Step 2: Convert to grayscale if it's RGB
if size(img, 3) == 3
    img = rgb2gray(img);
end

% Step 3: Convert to double
img = double(img);

% Step 4: Get image dimensions
[M, N] = size(img);

% Step 5: Compute Row Frequency (RF)
rf_sum = 0;
for i = 1:M
    for j = 1:N-1
        diff_val = img(i, j+1) - img(i, j);
        rf_sum = rf_sum + diff_val^2;
    end
end
RF = rf_sum / (M * N);

% Step 6: Compute Column Frequency (CF)
cf_sum = 0;
for j = 1:N
    for i = 1:M-1
        diff_val = img(i+1, j) - img(i, j);
        cf_sum = cf_sum + diff_val^2;
    end
end
CF = cf_sum / (M * N);

% Step 7: Compute Spatial Frequency (SF)
SF = sqrt(RF + CF);

% Step 8: Display result
fprintf('Spatial Frequency (SF): %.4f\n', SF);