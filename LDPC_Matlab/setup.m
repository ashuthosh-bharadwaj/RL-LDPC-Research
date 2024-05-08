addpath('./utils');
addpath('./Extra');

option = '5gnr'

switch option
    case 'wlan'
        load('./Base_Matrices/WLAN_12_24_81.mat');
        Z = 81;

        PCM = ldpcQuasiCyclicMatrix(Z,H);
        Encode_config = ldpcEncoderConfig(PCM);

        [numSubMatrixRows, numSubMatrixCols] = size(H); 
        numRows = Z*numSubMatrixRows;  
        numCols = Z*numSubMatrixCols;
        % (974,1944) = 81*(12,24)  

    case '5gnr'
        load('./Base_Matrices/NR_2_2_10.mat');
        Z = 10;

        PCM = ldpcQuasiCyclicMatrix(Z,H);
        Encode_config = ldpcEncoderConfig(PCM);

        [numSubMatrixRows, numSubMatrixCols] = size(H); 
        numRows = Z*numSubMatrixRows;  
        numCols = Z*numSubMatrixCols;
        % (420,520) = 10*(42,52) 
end

msg_len = numCols - numRows; % (n - (n-k) = k)
BitsinCheck = cell(numRows,1);

for row_num = 1:numRows
    
    SubMatrixRow = ceil(row_num/Z);
    temp =  [];

    for col = 1:numSubMatrixCols
        SubMatrixVal = H(SubMatrixRow, col);

        if SubMatrixVal ~= -1
           temp = [temp,  Z*(col-1) + mod(row_num + SubMatrixVal-1, Z) + 1];
        end
    end 

    BitsinCheck{row_num,1} = temp;
end

LLR_registers_init = cell(numRows,1);

for row_num = 1:numRows
    LLR_registers_init{row_num} = 0*BitsinCheck{row_num};
end 

clear temp;

% SUBMATRIX PRINTER %

% fileID = fopen('exp.txt','w');
% fprintf(fileID,'SubMatrix = ');

% fprintf(fileID,"{");
% for i = 1:size(H, 1)
%     fprintf(fileID,"{");
%     for j = 1:(size(H, 2)-1)
%         fprintf(fileID,'%d, ', H(i, j));
%     end
%     fprintf(fileID,'%d', H(i,size(H, 2)));

%     fprintf(fileID,"},");
%     fprintf(fileID,'\n');
% end
% fprintf(fileID,"}");
% fprintf(fileID,";");

% mex -setup c++
% mex -g Extra/layer_decode.cpp