clc; clear all; close all;

% visible image
vis = imread("manVB.jpg");
if size(vis, 3) == 3
    vis_gray = rgb2gray(vis);  % convert to grayscale if RGB
else
    vis_gray = vis;
end
vis_dbl = double(vis);
% figure(1)
subplot(2, 3, 1)
imshow(vis)
title('Visible image')

% infrared image
inf = imread("manIR.jpg");
if size(inf, 3) == 3
    inf_gray = rgb2gray(inf);
else
    inf_gray = inf;
end
inf_dbl = double(inf);
% figure(2)
subplot(2, 3, 4)
imshow(inf)
title('Infrared image')

% silent traget mask

salientMask = zeros(size(inf));
[m, n] = size(inf);

for i = 1:m
    for j = 1:n
        if inf_dbl(i, j) > 127
            salientMask(i, j) = 255;
        else
            salientMask(i, j) = 0;
        end
    end
end

% figure(3)
subplot(2, 3, 5)
imshow(uint8(salientMask))
title('Silent Target Mask')

r1 = double(inf_gray) .* rgb2gray(salientMask);

subplot(2, 3, 6)
imshow(uint8(r1))
title("Infrared x Silent Target Mask")

% background mask

bgMask = zeros(size(vis));
[m, n] = size(vis);

for i = 1:m
    for j = 1:n
        if vis_dbl(i, j) < 127
            bgMask(i, j) = 255;
        else
            bgMask(i, j) = 0;
        end
    end
end

% figure(3)
subplot(2, 3, 2)
imshow(uint8(bgMask))
title('Background Mask')

r2 = double(vis_gray) .* rgb2gray(bgMask);

subplot(2, 3, 3)
imshow(uint8(r2))
title("Visible x Background Mask")