I = 0;
I_max = 50;
S_ = zeros(num_clusters,1); 
ldpc_registers = cell(tau,1);

for i = 1:tau
    
    CNs = clusters{i};
    VNs = vns_in_cluster{i};
    
    num_cns = numel(CNs);
    num_vns = numel(VNs);
    
    ldpc_registers{i} = zeros(num_cns, num_vns);

end

message = zeros(1,msg_len);

codeword = mod(message*G,2);

channel_input = (1 - 2*codeword);
var = sqrt(10^(-1/10));
noise = var*randn(size(channel_input));
channel_output = channel_input + noise;

l = channel_output;

while I < I_max
    
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
     
    a = [];

    xhat = (l < 0);
    
    if mod(sum(PCM*xhat'),2) == 0
        break;
    end

    I = I + 1;
end