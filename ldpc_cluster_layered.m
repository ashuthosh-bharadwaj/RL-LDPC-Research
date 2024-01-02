
% get cluster alloc from pyscript before proceeding;

addpath('./LDPC_M')
addpath('./LDPC_M/utils')
load('./LDPC_M/Base_Matrices/WLAN_12_24_81.mat');
load('./LDPC_M/Imp.mat')
z = 81;

PCM = ldpcQuasiCyclicMatrix(z,H);
Encode_config = ldpcEncoderConfig(PCM);

[numSubMatrixRows, numSubMatrixCols] = size(H); 
numRows = z*numSubMatrixRows;  
numCols = z*numSubMatrixCols;
% 12, 24 

BitsinCheck = cell(numRows,1);

for row_num = 1:numRows
    
    SubMatrixRow = ceil(row_num/z);
    temp =  [];

    for col = 1:numSubMatrixCols
        SubMatrixVal = H(SubMatrixRow, col);

        if SubMatrixVal ~= -1
           temp = [temp,  z*(col-1) + mod(row_num + SubMatrixVal-1, z) + 1];
        end
    end 

    BitsinCheck{row_num,1} = temp;
end



SNRdB = -2:12;
snr_len = numel(SNRdB);
numIters = 20;
P_ecw = zeros(1, snr_len)
numTrials = 1e3;

tic 
for snr_idx = 1:snr_len

    snr = SNRdB(snr_idx);
    fprintf(1, 'SNR = %f \n',snr);
    N_errors = 0;

    parfor trial = 1:numTrials
        
        LLR_registers = cell(numRows,1);
        %if mod(trial, 50) == 0
        %   fprintf(1, 'trial = %d \n', trial);
        %end

        message = randi([0,1],1,972)';
        codeword = ldpcEncode(message, Encode_config);

        channel_input = (1 - 2*codeword);
        var = sqrt(10^(-1*snr/10));
        noise = var*randn(size(channel_input));
        channel_output = channel_input + noise;

        pos = 1;
        llr_in = pos*channel_output;
        r = llr_in;

        for row_num = 1:numRows
            LLR_registers{row_num} = 0*BitsinCheck{row_num};
        end 

        llr_out = r;

        layer_sum = zeros(numSubMatrixRows,numCols);

        % Layered decoder start
        for iter = 1:numIters

            for layer = 1:numSubMatrixRows

                for row_num = 1:z    
                    %disp(size(r(BitsinCheck{cluster_alloc(layer, row_num)})));
                    %disp(size(llr_out(BitsinCheck{cluster_alloc(layer, row_num)})));
                    %disp(size(layer_sum(layer, BitsinCheck{cluster_alloc(layer, row_num)})'));
                    %disp(size(LLR_registers{cluster_alloc(layer, row_num)}'));

                    r(BitsinCheck{cluster_alloc(layer, row_num)}) = llr_out(BitsinCheck{cluster_alloc(layer, row_num)}) + layer_sum(layer, BitsinCheck{cluster_alloc(layer, row_num)})' - LLR_registers{cluster_alloc(layer, row_num)}';
                end
                 
                for row_num = 1:z    
                    LLR_registers{cluster_alloc(layer, row_num)} = llr_out(BitsinCheck{cluster_alloc(layer, row_num)})' - LLR_registers{cluster_alloc(layer, row_num)};
                    LLR_registers{cluster_alloc(layer, row_num)} = Min(LLR_registers{cluster_alloc(layer, row_num)});
                    r(BitsinCheck{cluster_alloc(layer, row_num)}) = r(BitsinCheck{cluster_alloc(layer, row_num)}) + LLR_registers{cluster_alloc(layer, row_num)}';
                end              
                llr_out = r;
                
                L_storage = zeros(z,numCols);

                for row_num = 1:z
                    L_storage(row_num,BitsinCheck{cluster_alloc(layer, row_num)}) = LLR_registers{cluster_alloc(layer, row_num)};
                end 

                layer_sum(layer, :) = sum(L_storage);

            end

            if all((r<0) == codeword)
                break
            end

        end

        if any((r<0) ~= codeword)
            N_errors = N_errors + 1;
        end 
    end
    
    P_ecw(snr_idx) = N_errors;

end

P_ecw = P_ecw/numTrials;
save('./LC.mat')

%plot(SNRdB,P_ecw);
%xlabel('SNR (dB)');
%ylabel('Codeword error probability');
