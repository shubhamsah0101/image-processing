function o_img = PL(i_img, y)

    % Convert to double for calculations
    i_img = double(i_img);
    
    % size of image
    [m, n] = size(i_img);

    % Transformed image
    o_img = zeros(size(i_img));

    % transformed image
    for i = 1:m
        for j = 1:n
            o_img(i,j) = round((i_img(i,j) / 255) ^ y * 255);
        end
    end

    % Convert back to uint8 for image display
    o_img = uint8(o_img);

end