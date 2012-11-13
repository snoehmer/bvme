function [R] = rot_mat(angle)
%ROT_MAT computes a rotation matrix for angle (in radians)

    R = [cos(angle) -sin(angle); sin(angle) cos(angle)];

end

