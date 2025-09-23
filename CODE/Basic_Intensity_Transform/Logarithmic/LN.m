% To Transform a gray scale image to Logrrathimic Transform

% Transfer Function:    s = c * log(1 + r)
%             here,     s = output pixel value
%                       c = contant value
%                       r = input pixel value


function o_img = LN(i_img)

    % Convert to double for calculations
    i_img = double(i_img);

    % max pixel value
    mPxl = max(max(i_img));

    % computing L (smallest power of 2 >= max pixel value)
    i = 0;
    while true
        if mPxl <= 2^i
            l = 2^i;
            break;
        end
        i = i + 1;
    end

    % computing s
    s = log10(1 + i_img);

    % computing c
    c = l / (log10(1 + l));

    % transformed image
    o_img = round(c) .* s;

    % Convert back to uint8 for image display
    o_img = uint8(o_img);

end