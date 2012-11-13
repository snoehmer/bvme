function [] = display_matches(I1, kp1, I2, kp2)
%DISPLAY_MATCHES visualizes matches between 2 images

    if((size(kp1,1) ~= size(kp2,1)) || (size(kp1,1) ~= size(kp2,1)) || ...
            (size(kp1,1) == 0) || (size(kp1,2) == 0))
        disp('keypoints empty or dimension mismatch!');
        return;
    end

    kp_scalefactor = 10;

    images_size = [max(size(I1, 1), size(I2, 1)), size(I1, 2) + size(I2, 2)];
    offset_i2_x = size(I1,2) + 1;
    
    images = zeros(images_size);
    
    images(1:size(I1,1), 1:size(I1,2)) = I1(:,:);
    images(1:size(I2,1), offset_i2_x:offset_i2_x+size(I2,2)-1)= I2(:,:);
    
    kp1_scaled = kp1;
    kp1_scaled(3,:) = kp_scalefactor * kp1_scaled(3,:);
    
    kp2_shifted = kp2;
    kp2_shifted(1,:) = offset_i2_x + kp2_shifted(1,:);
    kp2_shifted(3,:) = kp_scalefactor * kp2_shifted(3,:);
    
    kp_lines_x = [kp1(1,:); kp2_shifted(1,:)];
    kp_lines_y = [kp1(2,:); kp2_shifted(2,:)];
    
    figure('name', 'matches between images');
    imshow(images);
    title('matches between images');
    hold on;
    vl_plotframe(kp1_scaled);
    vl_plotframe(kp2_shifted);
    line(kp_lines_x, kp_lines_y);
    
end

