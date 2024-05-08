setup;

% SNRdB = [-2:1:0, 0.25:0.25:3, 4:6];
% SNRdB = 1.75:0.25:3.5;
SNRdB = 1.75;
% SNRdB = -2;

snr_len = numel(SNRdB);
numIters = 20;
P_ecw = zeros(1, snr_len);
numTrials = 1e3;

Decoder_details = [numIters, numTrials];

tic
for snr_idx = 1:snr_len
    
     
    snr = SNRdB(snr_idx);
    fprintf(1, 'SNR = %f \n',snr);
    N_errors = 0;

    LLR = zeros(numTrials, numCols);
    CDW = zeros(numTrials, numCols);
    var = sqrt(10^(-1*snr/10));

    for trial = 1:numTrials
        message = randi([0,1],1,msg_len)';
        codeword = ldpcEncode(message, Encode_config);

        channel_input = (1 - 2*codeword); 
        noise = var*randn(size(channel_input));
        channel_output = channel_input + noise;

        LLR(trial,:) = channel_output;
        CDW(trial,:) = codeword;     
    end
    
    P_ecw(snr_idx) = layer_decode(LLR, logical(CDW), uint8(LDPC_details), uint32(Decoder_details), BitsinCheck, LLR_registers_init, channel_input, logical(codeword));
    
end
toc

P_ecw = P_ecw/numTrials;
save('./Output/Layered_newcheck.mat');