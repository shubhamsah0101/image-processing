% To Transform a gray scale image to Digital Negative

% Transfer Function:    s = (L - 1) - r
%             here,     s = output pixel value
%                       L = number of possible intensity level
%                       r = input pixel value

function o_img = DN(i_img)

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

    % transformed image
    o_img = (l - 1) - i_img;

    % Convert back to uint8 for image display
    o_img = uint8(o_img);
    
end