% To Transform a gray scale image to Logrrathimic Transform

% Transfer Function:    s = 255 if r > T    
%                               or
%                       s = 0   if r < T
%             here,     s = output pixel value
%                       T = Threshold value
%                       r = input pixel value


function o_img = TS(i_img)
    
    % Convert to double for calculations
    i_img = double(i_img);

    % size of image
    [m, n] = size(i_img);

    % transformed image
    o_img = zeros(size(i_img));

    for i = 1:m
        for j = 1:n
            if i_img(i,j) > 127
                o_img(i,j) = 255;
            else
                o_img(i,j) = 0;
            end
        end
    end

    % Convert back to uint8 for image display
    o_img = uint8(o_img);



end