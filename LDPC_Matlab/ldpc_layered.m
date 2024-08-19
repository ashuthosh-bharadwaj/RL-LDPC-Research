setup;

% SNRdB = 1:0.5:3.5;
Eb_NodB = 1:0.5:3.5;

snr_len = numel(Eb_NodB);
numIters = 50;
P_ecw = zeros(1, snr_len);
numTrials = 1e6;

parfor snr_idx = 1:snr_len

    snr = Eb_NodB(snr_idx);
    fprintf(1, 'SNR = %f \n',snr);
    var = sqrt(13*10^(-1*snr/10)/5);
    N_errors = 0;

    for trial = 1:numTrials
        
        LLR_registers = LLR_registers_init;

        % message = randi([0,1],1,msg_len)';
        % codeword = ldpcEncode(message, Encode_config);
        codeword = zeros(1,520);

        channel_input = (1 - 2*codeword);
        noise = var*randn(size(channel_input));
        channel_output = channel_input + noise;

        pos = 1;
        llr_in = pos*channel_output;
        r = llr_in;
        llr_out = r;
        
        
        % Layered decoder start
        for iter = 1:numIters

            for layer = 1:numSubMatrixRows

                for row_num = 1:Z    
                    r(BitsinCheck{(layer-1)*Z + row_num}) = llr_out(BitsinCheck{(layer-1)*Z + row_num}) - LLR_registers{(layer-1)*Z + row_num}';
                end
                 
                for row_num = 1:Z 
                    LLR_registers{(layer-1)*Z + row_num} = llr_out(BitsinCheck{(layer-1)*Z + row_num})' - LLR_registers{(layer-1)*Z + row_num};
                    LLR_registers{(layer-1)*Z + row_num} = Min(LLR_registers{(layer-1)*Z + row_num});
                    r(BitsinCheck{(layer-1)*Z + row_num}) = r(BitsinCheck{(layer-1)*Z + row_num}) + LLR_registers{(layer-1)*Z + row_num}';
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

P_ecw

[~,time_stamp] = system('echo $time_stamp')
save(['./Output/Layered_out_' , time_stamp(1:end-1) , '.mat']);
