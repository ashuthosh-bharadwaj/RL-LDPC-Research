snr = 1:0.5:3.5;
num_snr = numel(snr);
L = zeros(15000,520);
C = zeros(15000,520);

% Randomness controller
rng(1)

for i = 1:15000
    message = randi([0,1],1,100);
    codeword = ldpcEncode(message, Encode_config);

    channel_input = (1 - 2*codeword);
    var = sqrt(10^(-1*snr(randperm(num_snr,1))/10));
    noise = var*randn(size(channel_input));
    channel_output = channel_input + noise;

    llr_in = channel_output;
    L(i,:) = llr_in;
    C(i,:) = codeword;

end 

clear i message codeword noise channel_input channel_output llr_in var num_snr snr;
save('Datasets/LC_dataset.mat');
