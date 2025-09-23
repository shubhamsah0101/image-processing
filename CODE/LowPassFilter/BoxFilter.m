% To apply Box Low Pass Filter to a Gary Scale Image
% o_img = Output Image
% i_img = Input Image
% k     = kernel (like 3x3, 5x5, 7x7, etc.)

function o_img = BoxFilter(i_img, k)

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