function [avg_kernel] = task2_gen_avg(kernel_size)
%TASK2_GEN_AVG generates an average/blur filter kernel
%   all values are the same (1/(size*size))

    avg_kernel = 1/(kernel_size * kernel_size) * ones(kernel_size, kernel_size);
    
end

