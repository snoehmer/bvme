function [kp_match1, kp_match2] = simple_matching(keypoints1, descriptors1, keypoints2, descriptors2)
%SIMPLE_MATCHING performs simple matching between two keypoints/descriptors sets
%   matching is done using Euclidean distances, ambiguous matches are discarded

    distance_threshold = 0.2;
    discard_ratio = 0.7;  % discard if ratio between 2 best matches is higher

    kp_match1 = [];
    kp_match2 = [];
    
    % find the 2 best matches for each keypoint
    for i = 1:size(keypoints1, 2)
        
       % generate a matrix for current keypoint1
       D1 = repmat(descriptors1(:, i), 1, size(keypoints2, 2));
       
       distance = sum((D1 - descriptors2) .^ 2, 1);
       
       % sort by distance
       [~, min_idx] = sort(distance, 'ascend');
       
       % calculate the minimum distance
       min_dist = distance(min_idx(1));
       
       % calculate ratio between best match and 2nd best match
       ratio = distance(min_idx(1)) / distance(min_idx(2));
       
       % add to the detected matches, if the ratio is smaller than the threshold
       if min_dist < distance_threshold && ratio <= discard_ratio
           kp_match1 = [kp_match1 keypoints1(:,i)];
           kp_match2 = [kp_match2 keypoints2(:,min_idx(1))];
       end
        
    end

end

