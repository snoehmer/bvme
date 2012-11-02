function [image_out] = task2_filter(image_in, type, param)
%TASK2_FILTER generates the filter kernel and filters the image
%   possible types are avg, gauss and median, the parameter is:
%    - for avg and median: param is the kernel size
%    - for gauss: param is sigma

    if(strcmpi(type, 'avg'))
        
        avg_kernel = task2_gen_avg(param);
        
        image_out = task2_conv(image_in, avg_kernel);
        
    elseif(strcmpi(type, 'gauss'))
        
        gauss_kernel = task2_gen_gauss(param);
        
        image_out = task2_conv(image_in, gauss_kernel);
        
    elseif(strcmpi(type, 'median'))
        
        image_out = task2_median(image_in, param);
        
    else
        
        disp('ERROR: filter type unknown');
        image_out = 0;
        
    end
    
end

