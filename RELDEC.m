workspace
load('LDPC_Matlab/Datasets/LC_dataset.mat');
load('LDPC_Matlab/Datasets/LDPC_init.mat');
addpath('LDPC_Matlab/utils');

PCM = full(PCM);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

int_m = @(x) bin2dec(strjoin(string(1*(x))));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
max_la = 0;
for i=1:num_clusters
    max_la = max(max_la, numel(vns_in_cluster{i,1}));
end

z = numel(clusters{1});
tau = num_clusters;

if tau == ceil(numSubMatrixRows*Z/z)
    disp("Sanity checked");
end 

ldpc_registers = cell(tau,1);

for i = 1:tau
    
    CNs = clusters{i};
    VNs = vns_in_cluster{i};
    
    num_cns = numel(CNs);
    num_vns = numel(VNs);
    
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

[ndata, ~] = size(L);

S = zeros(num_clusters,1);

for idx = 1:ndata
    l = L(idx,:);
    c = C(idx,:);

    l_ = 0;
    L_hat_l_ = l;

    for c_idx = 1:num_clusters
        S(c_idx) = int_m(l(vns_in_cluster{c_idx}) >= 0);
    end
    
    while l_ < l_max

        if rand <= epsilon
            a = randi(tau,1);
        else
            QQ = zeros(tau,1);
    
            for i = A
                QQ(i) = Q(i, S(i)+1);
            end

            [~,a] = max(QQ);
        end
        
        local_flood; %(tanh first and sum second)

        x_hat_a = vns_in_cluster{a} >= 0;

        s_a = int_m(x_hat_a);

        Reward_a = (1/numel(vns_in_cluster{a}))*(sum(c(vns_in_cluster{a}) == x_hat_a));

        S(a) = s_a;

        for i = A
            QQ(i) = Q(i, S(i)+1);
        end

        Q(a, S(a)+1) = (1-alpha)*Q(a, S(a)+1) + alpha*(Reward_a + beta*(max(QQ))); %fix here 
        
        l_ = l_ + 1;

    end

end



















