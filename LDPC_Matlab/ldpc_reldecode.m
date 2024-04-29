setup;
RELDEC;

%SNRdB = [-2:1:0, 0.25:0.25:3, 4:6];
% SNRdB = 1.75:0.25:3.5;
SNRdB = 1:0.5:3.5;


snr_len = numel(SNRdB);
numIters = 50;
P_ecw = zeros(1, snr_len);
numTrials = 1e5;

tic 
for snr_idx = 1:snr_len

    snr = SNRdB(snr_idx);
    fprintf(1, 'SNR = %f \n',snr);
    var = sqrt(10^(-1*snr/10));
    N_errors = 0;

    for trial = 1:numTrials

        message = randi([0,1],1,msg_len)';
        codeword = ldpcEncode(message, Encode_config);

        channel_input = (1 - 2*codeword);
        noise = var*randn(size(channel_input));
        channel_output = channel_input + noise;

        pos = 1;
        llr_in = pos*channel_output;
        l = llr_in;


        S_ = zeros(num_clusters,1); 
        ldpc_registers = cell(tau,1);

        for i = 1:tau
            
            CNs = clusters{i};
            VNs = vns_in_cluster{i};
            
            num_cns = numel(CNs);
            num_vns = numel(VNs);
            
            ldpc_registers{i} = zeros(num_cns, num_vns);

        end

        % RELDECODER start 
        for iter = 1:numIters
            
            for c_idx = 1:num_clusters
                S_(c_idx) = int_m(l(vns_in_cluster{c_idx}) >= 0);
            end
        
            Q_req = zeros(tau,1);
            
            for i = A
                Q_req(i) = Q(i, S_(i) + 1);
            end
            
            [~, schedule] = sort(Q_req,'descend');
        
            for a = schedule'
                local_flood;
            end
        
            xhat = (l < 0);
            
            if all(xhat == codeword)
                break
            end
        end

        if any(xhat ~= codeword)
            N_errors = N_errors + 1;
        end 
   
    end

    P_ecw(snr_idx) = N_errors;

end
toc

P_ecw


