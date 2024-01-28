setup;

%SNRdB = [-2:1:0, 0.25:0.25:3, 4:6];
% SNRdB = 1.75:0.25:3.5;
SNRdB = 1.75;

snr_len = numel(SNRdB);
numIters = 20;
P_ecw = zeros(1, snr_len);
numTrials = 1e3;

tic 
for snr_idx = 1:snr_len

    snr = SNRdB(snr_idx);
    fprintf(1, 'SNR = %f \n',snr);
    N_errors = 0;

    for trial = 1:numTrials
        
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
        
        
        % Layered decoder start
        for iter = 1:numIters

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
save('./Output/Layered.mat');

