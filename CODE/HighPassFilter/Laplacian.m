% LAPLACIAN HIGHPASS FILTER

function o_img = Laplacian(i_img)

    % Convert image to double
    i_img = double(i_img);

    % Get size of image
    [m, n] = size(i_img);

    % Define 3x3 Laplacian kernel (4-neighbor)
    kernel = [0 1 0; 1 -4 1; 0 1 0];
    % kernel = [1 1 1; 1 -8 1; 1 1 1];
    % kernel = [0 -1 0; -1 4 -1; 0 -1 0];
    % kernel = [-1 -1 -1; -1 8 -1; -1 -1 -1];

    % zero padding
    padded = zeros(m+2, n+2);
    padded(2:m+1, 2:n+1) = i_img;

    % Output image
    o_img = zeros(m, n);

    % Manual convolution
    for i = 2:m+1
        for j = 2:n+1
            sum = 0;
            for a = -1:1 
                for b = -1:1
                    sum = sum + kernel(a+2, b+2) * padded(i+a, j+b);
                end
            end
            o_img(i-1, j-1) = sum;
        end
    end

    % Normalize to 0–255 range
    % o/p = (o/p - min) / (max - min)
    min_val = min(o_img(:));
    max_val = max(o_img(:));
    o_img = (o_img - min_val) / (max_val - min_val) * 255;

    % Convert to uint8
    o_img = uint8(o_img);

end
