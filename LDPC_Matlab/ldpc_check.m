setup;

% SNRdB = [-2:1:0, 0.25:0.25:3, 4:6];
SNRdB = 1.75:0.25:3.5;
% SNRdB = -2;

snr_len = numel(SNRdB);
numIters = 20;
P_ecw = zeros(1, snr_len);
numTrials = 1000;

tic 
for snr_idx = 1:snr_len

    snr = SNRdB(snr_idx);
    fprintf(1, 'SNR = %f \n',snr);
    N_errors = 0;

    for trial = 1:numTrials

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
        
        LDPC_details = [numSubMatrixRows, z];

        decode_result = layer_decode(llr_out, logical(codeword), uint8(LDPC_details), numIters, BitsinCheck, LLR_registers);
        N_errors = N_errors + (~decode_result);
    end

    P_ecw(snr_idx) = N_errors   

end
toc

P_ecw = P_ecw/numTrials;
save('./Output/Layered_newcheck.mat');