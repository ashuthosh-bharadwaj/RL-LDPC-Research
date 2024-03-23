load('LDPC_Matlab/Datasets/LC_dataset.mat');
load('LDPC_Matlab/Datasets/LDPC_init.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
max_la = 0;
for i=1:num_clusters
    max_la = max(max_la, numel(vns_in_cluster{i,1}));
end

z = numel(clusters{1});
tau = num_clusters;

if tau == ceil(numSubMatrixRows/Z)
    disp("Sanity checked");
end 

ldpc_registers = cell(tau,1);

for i = 1:tau
    
    CNs = clusters{i};
    VNs = vns_in_cluster{i};
    
    num_vns = numel(CNs);
    num_cns = numel(VNs);
    
    ldpc_registers{i} = zeros(num_cns, num_vns);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

l_max = 50;
epsilon = 0.7;
alpha = 0.1;
beta = 0.9;

A = 1:tau;
num_states = 2^max_la;
Q = zeros(tau,num_states);


load('./LDPC_Matlab/L_dataset.mat');
load('./LDPC_Matlab/C_dataset.mat');

[ndata, ~] = size(L);


S = zeros(num_clusters,1);

for idx = 1:ndata
    l = L(idx,:);
    c = C(idx,:);

    l_ = 0;
    L_hat_l_ = l;


    for c_idx = 1:num_clusters
        S(c_idx) = bin2dec(strjoin(string(l(vns_in_cluster{c_idx}) >= 0)));
    end
    
    while l_ < l_max

        if rand <= epsilon
            a = randi(tau,1);
        else
            QQ = zeros(tau,1);
            for i = A
                QQ(i) = Q(A(i), S(i));
            end

            [~,a] = max(QQ);
            a = A(a);
        end
        
        local_flood; %(tanh first and sum second)

        x_hat_a = vns_in_cluster{a} >= 0;

        s_a = bin2dec(strjoin(string(x_hat_a)));

        Reward_a = (1/numel(vns_in_cluster{a}))*(sum(c(vns_in_cluster) == x_hat_a));

        Q(a, S(a)) = (1-alpha)*Q(a, S(a)) + alpha*(Reward_a + beta*(max(Q(:, s_a)))); %fix here 
        l_ = l_ + 1;
        S(a) = s_a;

    end

end