% To apply Median Low Pass Filter to a Gary Scale Image 

function o_img = Median(i_img, k)

    i_img = double(i_img);

    % padding size
    p_size = floor(k / 2);
    
    % size of image
    [m, n] = size(i_img);

    % zero padding
    p = zeros(m + 2*p_size, n + 2*p_size);
    p(p_size + 1 : end - p_size, p_size + 1 : end - p_size) = i_img;

    % output image
    o_img = zeros(m, n);

    % applying filter
    for i = 1:m
        for j = 1:n
            region = p(i : i + 2*p_size, j : j + 2*p_size);
            values = region(:);
            o_img(i, j) = median(values);
        end
    end

    o_img = uint8(o_img(p_size+1:end-p_size, p_size+1:end-p_size));

end