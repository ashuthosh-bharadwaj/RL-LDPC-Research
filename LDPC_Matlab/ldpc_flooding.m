setup;

%SNRdB = [-2:1:0, 0.25:0.25:3, 4:6];
%SNRdB = -2;
SNRdB = 1.75:0.25:3.5;

snr_len = numel(SNRdB);
numIters = 20;
P_ecw = zeros(1, snr_len);
numTrials = 1e5;


tic 
for snr_idx = 1:snr_len

    snr = SNRdB(snr_idx);
    fprintf(1, 'SNR = %f \n',snr);
    N_errors = 0;

    parfor trial = 1:numTrials
        
        LLR_registers = cell(numRows,1);

        message = randi([0,1],1,msg_len)';
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

        % Flooding decoder start
        for iter = 1:numIters

            for row_num = 1:numRows
                LLR_registers{row_num} = llr_out(BitsinCheck{row_num})' - LLR_registers{row_num};
                LLR_registers{row_num} = Min(LLR_registers{row_num});
                r(BitsinCheck{row_num}) = r(BitsinCheck{row_num}) +  LLR_registers{row_num}';
            end 
            llr_out = r;

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
save('./Output/Flooding.mat');