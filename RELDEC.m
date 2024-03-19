load('Datasets/LC_dataset.mat');
load('Datasets/LDPC_init.mat');


max_la = 0;
for i=1:num_clusters
    max_la = max(max_la, numel(vns_in_cluster{i,1}));
end

z = numel(clusters{1});
tau = ceil(numSubMatrixRows/Z);

l_max = 50;
epsilon = 0.7;
alpha = 0.1;
beta = 0.9;

A = 0:1:tau;
Q = zeros(tau,2^max_la);


load('./LDPC_Matlab/L_dataset.mat');
load('./LDPC_Matlab/C_dataset.mat');

ndata = size(L);
ndata = ndata(1);

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
            Valid_states = Q(:, S);
            [~,a] = max(Valid_states(:));
            
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