% EDGE DETECTION USING SOBEL OPERATOR

function edge_img = Sobel(i_img)
    
    % Convert to double
    i_img = double(i_img);

    % Get image size
    [m, n] = size(i_img);

    % Define Sobel kernels
    Gx = [-1  0  1; -2 0 2; -1 0 1];  % Horizontal edges
    Gy = [-1 -2 -1;  0 0 0;  1 2 1];  % Vertical edges

    % Zero-padding the image
    padded = zeros(m+2, n+2);
    padded(2:m+1, 2:n+1) = i_img;

    % Initialize output image
    edge_img = zeros(m, n);

    % Manual convolution
    for i = 2:m+1
        for j = 2:n+1
            sum_x = 0;
            sum_y = 0;
            for a = -1:1
                for b = -1:1
                    pixel = padded(i+a, j+b);
                    sum_x = sum_x + Gx(a+2, b+2) * pixel;
                    sum_y = sum_y + Gy(a+2, b+2) * pixel;
                end
            end
            % Compute gradient magnitude
            edge_mag = sqrt(sum_x^2 + sum_y^2);
            edge_img(i-1, j-1) = edge_mag;
        end
    end

    % Normalize result to 0–255 range manually
    min_val = min(edge_img(:));
    max_val = max(edge_img(:));
    edge_img = (edge_img - min_val) / (max_val - min_val) * 255;

    % Convert to uint8
    edge_img = uint8(edge_img);

end