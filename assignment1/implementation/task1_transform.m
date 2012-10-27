function [y_in, x_in] = task1_transform(y_out, x_out, angle)
%TASK1_TRANSFORM calculate the coordinate transformation for rotation
%   this function returns the transformed coordinates for rotation

    angle_rad = angle * pi / 180;
    R_inv = [cos(angle_rad) sin(angle_rad); -sin(angle_rad) cos(angle_rad)];
    X_out = [y_out; x_out];
    
    X_in = R_inv * X_out;
    
    y_in = X_in(1);
    x_in = X_in(2);
        
end

