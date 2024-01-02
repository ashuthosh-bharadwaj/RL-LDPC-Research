numSubMatrixRows = 2;
z = 2;
r = [0.2, -0.3, 1.2, -0.5, 0.8, 0.6, -1.1]';

BitsinCheck = {[1,2,3,5];[4,6,7];[1,2,4,7];[3,5,6]};

LLR_registers = cell(4,1);
llr_out = r;
for row_num = 1:4
    LLR_registers{row_num} = 0*BitsinCheck{row_num};
end 

for i = 1:2
    disp(i)
for layer = 1:numSubMatrixRows
    
    for row_num = 1:z
        r(BitsinCheck{(layer-1)*z + row_num}) = llr_out(BitsinCheck{(layer-1)*z + row_num}) - LLR_registers{(layer-1)*z + row_num}';
    end
    
    for row_num = 1:z
        disp(BitsinCheck{(layer-1)*z + row_num}); disp(LLR_registers{(layer-1)*z + row_num})   
        LLR_registers{(layer-1)*z + row_num} = llr_out(BitsinCheck{(layer-1)*z + row_num})' - LLR_registers{(layer-1)*z + row_num};
        disp(LLR_registers{(layer-1)*z + row_num}) 
        
        LLR_registers{(layer-1)*z + row_num} = Min(LLR_registers{(layer-1)*z + row_num});
        
        disp(LLR_registers{(layer-1)*z + row_num}) 
        r(BitsinCheck{(layer-1)*z + row_num}) = r(BitsinCheck{(layer-1)*z + row_num}) + LLR_registers{(layer-1)*z + row_num}';
    end              
    llr_out = r;
end
end