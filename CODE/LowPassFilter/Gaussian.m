% To apply Gaussian Low Pass Filter to a Gary Scale Image 

function o_img = Gaussian(i_img, k, sigma)
    
    % padding size
    p_size = floor(k/2);

    % image size
    [m, n] = size(i_img);

    % creating gaussian filter
    g = zeros(k, k);

    for i = 1:k
        for j = 1:k
            % center kernel
            x = i - p_size - 1;
            y = j - p_size - 1;
            g(i,j) = exp(-(x^2 + y^2) / (2 * sigma^2));
        end
    end

    g = g / sum(g(:));

    % zero padding
    p = zeros(m + 2*p_size, n + 2*p_size);
    p(p_size + 1 : end - p_size, p_size + 1 : end - p_size) = i_img;

    % output image
    o_img = zeros(m, n);

    % applying gaussian filter
    for i = 1:m
        for j = 1:n
            region = p(i : i + 2*p_size, j : j + 2*p_size);
            o_img(i, j) = sum(sum(region .* g));
        end
    end

    o_img = uint8(o_img);

end