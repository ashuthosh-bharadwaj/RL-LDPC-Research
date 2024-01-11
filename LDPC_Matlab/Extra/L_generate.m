load('./Base_Matrices/NR_2_2_10.mat');
snr = -2:12;
num_snr = numel(snr);
L = [];
C = [];

for i = 1:5000
    message = randi([0,1],1,100);
    codeword = encoder(H, 10, message);

    channel_input = (1 - 2*codeword);
    var = sqrt(10^(-1*snr(randperm(num_snr,1))/10));
    noise = var*randn(size(channel_input));
    channel_output = channel_input + noise;

    pos = 1;
    llr_in = pos*channel_output;
    L = [L; llr_in];
    C = [C; codeword];

end 

save('L_dataset.mat')