% Based on given cluster, find the right set of var nodes and checknodes and commence flooding; 

for layer = 1:numSubMatrixRows

    for row_num = 1:z    
        r(BitsinCheck{(layer-1)*z + row_num}) = llr_out(BitsinCheck{(layer-1)*z + row_num}) - LLR_registers{(layer-1)*z + row_num}';
    end
        
    for row_num = 1:z    
        LLR_registers{(layer-1)*z + row_num} = llr_out(BitsinCheck{(layer-1)*z + row_num})' - LLR_registers{(layer-1)*z + row_num};
        LLR_registers{(layer-1)*z + row_num} = Min(LLR_registers{(layer-1)*z + row_num});
        r(BitsinCheck{(layer-1)*z + row_num}) = r(BitsinCheck{(layer-1)*z + row_num}) + LLR_registers{(layer-1)*z + row_num}';
    end              
    llr_out = r;
end
