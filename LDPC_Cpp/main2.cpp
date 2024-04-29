#include <iostream>
#include <random>
#include "ldpc_encoder.h"
#include "Extra_mats.h"
#define  num_snr  8


double SNRdB[num_snr] = {1.75, 2.00, 2.25, 2.50, 2.75, 3.00, 3.25, 3.50};
// double SNRdB[num_snr] = {1.75};
int Errors[num_snr];

using namespace std;

normal_distribution<double> gauss_dist(0.0f, 1.0);
default_random_engine generator;

int sign_fn(double x){ return ((x < 0) ? (-1) : (1));}

unsigned numvars(int * arr, int max_non_null)
{
    unsigned i=0;  
    while((arr[i] != -1) && (i<=(max_non_null-1))){ i++;}
    return i;
}

int main(){
    
    LdpcCode ldpc_code(0, 0);

    unsigned code_len = 1944;

    ldpc_code.load_wifi_ldpc(code_len);
    
    unsigned K = ldpc_code.get_info_length();
    unsigned z =  ldpc_code.get_expfactor();

    unsigned m = ldpc_code.get_submatrow();
    unsigned n = ldpc_code.get_submatcol();

    unsigned M = ldpc_code.get_matrow();
    unsigned N = ldpc_code.get_matcol();

    unsigned max_non_null = ldpc_code.get_max_nonnull();

    int * h_pointer = ldpc_code.get_h_pointer();

    cout<<*(h_pointer)<<endl;

    int SubMatrix[m][n];

    copy(h_pointer, h_pointer + m*n, &SubMatrix[0][0]);
    
    cout<<SubMatrix[0][0]<<" is equal to 57! looks like it worked"<<endl;
    exit(0);

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

}