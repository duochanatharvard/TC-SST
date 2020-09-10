function output = CDC_block_permutation(input,N,block_size)

    N_block = ceil(numel(input)/block_size);
    input2  = input; 
    input2(:,(end+1):(N_block*block_size)) = nan;
    
    output = nan(numel(input),N);
    for ct = 1:N
        
        clear('temp','a')
        a = randperm(N_block);
        for ct_blk = 1:N_block
            temp((ct_blk - 1) * block_size + [1:block_size]) = ...
                     input2((a(ct_blk) - 1) * block_size + [1:block_size]);
        end
        temp(isnan(temp)) = [];
        output(:,ct) = temp;
    end
    
end