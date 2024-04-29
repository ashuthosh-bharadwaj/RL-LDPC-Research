#include <iostream>
#include <random>
#include "ldpc_encoder.h"
#define  num_snr  1

// double SNRdB[num_snr] = {1.75, 2.00, 2.25, 2.50, 2.75, 3.00, 3.25, 3.50};
double SNRdB[num_snr] = {-1};
int Errors[num_snr];

using namespace std;

normal_distribution<double> gauss_dist(0.0f, 1.0);
default_random_engine generator;



unsigned numvars(int * arr, int max_non_null)
{
    unsigned i=0;  
    while((arr[i] != -1) && (i<=(max_non_null-1))){ i++;}
    return i;
}

/*int main(){
    
    LdpcCode ldpc_code(0, 0);

    unsigned code_len = 520;

    ldpc_code.load_wifi_ldpc(code_len);
    
    unsigned K = ldpc_code.get_info_length();
    unsigned z =  ldpc_code.get_expfactor();

    unsigned m = ldpc_code.get_submatrow();
    unsigned n = ldpc_code.get_submatcol();

    unsigned M = ldpc_code.get_matrow();
    unsigned N = ldpc_code.get_matcol();

    unsigned max_non_null = ldpc_code.get_max_nonnull();
    
    int * h_pointer = ldpc_code.get_h_pointer();

    int SubMatrix[m][n];

    copy(h_pointer, h_pointer + m*n, &SubMatrix[0][0]);
    
    int BitsinCheck[M][max_non_null];
    double LLR_init[M][max_non_null];

    for(int i=0; i < M; i++)
    {
        for(int j=0; j < max_non_null; j++)
        {
            BitsinCheck[i][j] = -1;
            LLR_init[i][j] = 0;
        }
    }

    int SubMatrixVal, idx, SubMatrixRow;

    for(int row_num = 0; row_num < M; row_num++)
    {
        SubMatrixRow = (row_num/z);
        idx = 0;
        
        for(int col = 0; col < n; col++)
        {   
            SubMatrixVal = SubMatrix[SubMatrixRow][col];

            if(SubMatrixVal != -1)
            {
                BitsinCheck[row_num][idx] = z*(col) + ((row_num + SubMatrixVal)%z);
                idx++;
            }
        }
    }

    double LLR_registers[M][max_non_null];

    int numvars_arr[M];

    for(int i=0; i < M; i += z)
    {
        int tmp = numvars(BitsinCheck[i], max_non_null);

        for(int j =0; j< z; j++)
            numvars_arr[i+j] = tmp;
    }

    vector<double> noise(code_len, 0);
    vector<double> channel_output(code_len,0);
    unsigned info_length = K;
    vector<int> info_bits(info_length, 0);
    double snr;
    double var;
    
    // ENCODER run for init
    for (unsigned i_bit = 0; i_bit < info_length; ++i_bit)
    {
        info_bits.at(i_bit) = (int) (rand() % 2);
    }
    vector<int> codeword = ldpc_code.encode(info_bits, &(SubMatrix[0][0]));\
    // ENCODER end for init 
    
    
    // DECODER START

    unsigned numIters = 10;
    unsigned numTrials = 1000;

    LdpcDecode ldpc_decode(numIters, N, m, z, &(numvars_arr[0])); 

    for(unsigned snr_idx=0; snr_idx < num_snr; snr_idx++)
    {
        snr = SNRdB[snr_idx];
        N_errors = 0;
        var = sqrt(1/pow(10, snr/10)); 

        for(unsigned trial=0; trial < numTrials; trial++)
        {   
            // ENCODER BEGIN    
            for (unsigned i_bit = 0; i_bit < info_length; ++i_bit)
            {
                info_bits.at(i_bit) = (int) (rand() % 2);
            }
            codeword = ldpc_code.encode(info_bits, &(SubMatrix[0][0]));
            // ENCODER END      

            //  TRANSMITTED TO CHANNEL 
            for (unsigned i = 0; i < code_len ; i++) 
            {
                noise.at(i) = (double) gauss_dist(generator);
                channel_output.at(i) =  (double) (1 - 2*(codeword.at(i))) + var*noise.at(i);
            }
            //  CHANNEL LLRs CREATED

            r = channel_output;
            llr_out = r;

            // init LLR_register to 0s
            copy(&LLR_init[0][0], &LLR_init[0][0]+M*max_non_null, &LLR_registers[0][0]);
            
            decoded = ldpc_decode.layered_decoder(channel_output,codeword, &(BitsinCheck[0][0]) , &(LLR_registers[0][0]));

            if(!decoded){N_errors++;}
        }

        cout<<"The num errors for snr="<<snr<<" and "<<numTrials<<" trials for "<<numIters<<" iters is  "<<N_errors<<endl;
        Errors[snr_idx] = N_errors;

    }
}*/

int main(){
    LdpcCode ldpc_code(0, 0);

    unsigned code_len = 520;

    ldpc_code.load_wifi_ldpc(code_len);
    
    unsigned K = ldpc_code.get_info_length();
    unsigned z =  ldpc_code.get_expfactor();

    unsigned m = ldpc_code.get_submatrow();
    unsigned n = ldpc_code.get_submatcol();

    unsigned M = ldpc_code.get_matrow();
    unsigned N = ldpc_code.get_matcol();

    unsigned max_non_null = ldpc_code.get_max_nonnull();
    
    int * h_pointer = ldpc_code.get_h_pointer();

    cout<<"Hi!"<<endl;

    int BitsinCheck[M][max_non_null];
    ldpc_code.Create_BinC(&(BitsinCheck[0][0]));
    
    cout<<"Bye!"<<endl;

    int SubMatrix[m][n];

    copy(h_pointer, h_pointer + m*n, &SubMatrix[0][0]);
    
    int BitsinCheck2[M][max_non_null];
    double LLR_init[M][max_non_null];

    for(int i=0; i < M; i++)
    {
        for(int j=0; j < max_non_null; j++)
        {
            BitsinCheck2[i][j] = -1;
            LLR_init[i][j] = 0;
        }
    }

    int SubMatrixVal, idx, SubMatrixRow;

    for(int row_num = 0; row_num < M; row_num++)
    {
        SubMatrixRow = (row_num/z);
        idx = 0;
        
        for(int col = 0; col < n; col++)
        {   
            SubMatrixVal = SubMatrix[SubMatrixRow][col];

            if(SubMatrixVal != -1)
            {
                BitsinCheck2[row_num][idx] = z*(col) + ((row_num + SubMatrixVal)%z);
                idx++;
            }
        }
    }
}