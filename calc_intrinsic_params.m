%% Function to form the intrinsic matrix of the camera
% Pass as parameters the focal length and sensor dimensions and resolution
function [intrinsic] = calc_intrinsic_params(film_size, resolution, focal_length)
    pixel_w = film_size(1,1)/resolution(1,1);
    pixel_h = film_size(1,2)/resolution(1,2);
    
    % Calculate focal length in pixels
    if (length(focal_length) == 1)
        fx = focal_length * (pixel_w/film_size(1,1));
        fy = focal_length * (pixel_h/film_size(1,2));
    else
        fx = focal_length(1,1) * (pixel_w/film_size(1,1));
        fy = focal_length(1,2) * (pixel_h/film_size(1,2));
    end
    
    % Calculate the principal point
    cx = resolution(1,1)/2;
    cy = resolution(1,2)/2;
    
    % Putting it together
    intrinsic = eye(3,3);
    intrinsic(1,1) = fx; intrinsic(2,2) = fy;
    intrinsic(3,1) = cx; intrinsic(3,2) = cy;
end
