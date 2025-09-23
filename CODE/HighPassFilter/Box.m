function o_img = Box(i_img, k)

    % padding size
    p_size = floor(k / 2);
    
    % size of input image
    [m, n] = size(i_img);

    % zero padding
    p = zeros(m + (2*p_size), n + (2*p_size));
    p(p_size + 1 : end - p_size, p_size + 1 : end - p_size) = i_img;

    % output image
    o_img = zeros(m, n);

    % applying filter
    for i = 1:m
        for j = 1:n
            region = p(i : i + (2*p_size), j : j + (2 * p_size));
            o_img(i,j) = sum(region(:)) / (k * k);
        end
    end
    
    o_img = uint8(o_img(p_size+1:end-p_size, p_size+1:end-p_size));

end