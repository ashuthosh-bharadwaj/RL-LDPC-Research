%setup
cd ..
RELDEC; 

SNRdB = 1:0.5:3.5;

snr_len = numel(SNRdB);
numIters = 50;
P_ecw = zeros(1, snr_len);
numTrials = 1e6;

Err_in_cdw = zeros(1, 2^(msg_len));

parfor snr_idx = 1:snr_len

    snr = SNRdB(snr_idx);
    fprintf(1, 'SNR = %f \n',snr);
    var = sqrt(10^(-1*snr/10));
    N_errors = 0;

    for trial = 1:numTrials

        message = randi([0,1],1,msg_len);
        counter = bin2dec(num2str(message)) + 1; 
        codeword = mod(message*G,2);

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
                S_(c_idx) = int_m(l(vns_in_cluster{c_idx}) < 0);
            end
        
            Q_req = zeros(tau,1);
            
            for i = A
                Q_req(i) = Q(i, S_(i) + 1);
            end
            
            [~, schedule] = sort(Q_req,'descend');
        
            for a = schedule'
                % Based on given cluster, find the right set of var nodes and checknodes and commence flooding; 
                CNs = clusters{a};
                VNs = vns_in_cluster{a};

                num_cns = numel(CNs);
                num_vns = numel(VNs);

                idxmap_C = dictionary(1:num_cns, CNs);
                idxmap_V = dictionary(VNs, 1:num_vns);


                current = ldpc_registers{a};


                % C -> V

                for cn_idx = 1:num_cns

                    places = BitsinCheck{idxmap_C(cn_idx)};
                    current(cn_idx, idxmap_V(places)) = l(places) -  current(cn_idx, idxmap_V(places));

                    Mforw = tanh(current(cn_idx, idxmap_V(places))/2);
                    product = prod(Mforw);
                   
                    Mforw = product./Mforw;
                    Mforw_parity = sign(1+ 2*sign(Mforw));
                    Mforw = 2*atanh(Mforw_parity.*min(abs(Mforw), 0.9999787));
                    
                    current(cn_idx, idxmap_V(places)) = Mforw;

                end


                % V -> C

                l(VNs) = l(VNs) + sum(current,1);

                ldpc_registers{a} = current; % re-init for self-belief removal

            end
        
            xhat = (l < 0);
            
            if all(xhat == codeword)
                break
            end
        end

        if any(xhat ~= codeword)
            N_errors = N_errors + 1;
            Err_in_cdw(counter)  = Err_in_cdw(counter) + 1;
        end 
   
    end

    P_ecw(snr_idx) = N_errors;

end

P_ecw

Err_in_cdw

