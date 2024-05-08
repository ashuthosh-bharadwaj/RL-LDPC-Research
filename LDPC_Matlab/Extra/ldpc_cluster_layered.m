setup;

% get cluster alloc from pyscript before proceeding;
load('./utils/Cluster.mat');


%SNRdB = [-2:1:0, 0.25:0.25:3, 4:6];
SNRdB = -2:12;
% SNRdB = 1.75:0.25:3.5;

snr_len = numel(SNRdB);
numIters = 20;
P_ecw = zeros(1, snr_len);
numTrials = 1e3;

tic 
for snr_idx = 1:snr_len

    snr = SNRdB(snr_idx);
    fprintf(1, 'SNR = %f \n',snr);
    N_errors = 0;

    parfor trial = 1:numTrials
        
        LLR_registers = LLR_registers_init;

        message = randi([0,1],1,msg_len)';
        codeword = ldpcEncode(message, Encode_config);

        channel_input = (1 - 2*codeword);
        var = sqrt(10^(-1*snr/10));
        noise = var*randn(size(channel_input));
        channel_output = channel_input + noise;

        pos = 1;
        llr_in = pos*channel_output;
        r = llr_in;
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

                    r(BitsinCheck{cluster_alloc(layer, row_num)}) = llr_out(BitsinCheck{cluster_alloc(layer, row_num)}) + layer_sum(layer, BitsinCheck{cluster_alloc(layer, row_num)})' - 2*LLR_registers{cluster_alloc(layer, row_num)}';
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
toc

P_ecw = P_ecw/numTrials;
save('./Output/Cluster_layered.mat');

