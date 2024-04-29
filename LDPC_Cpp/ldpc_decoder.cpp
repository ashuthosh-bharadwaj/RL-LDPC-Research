#include "ldpc_decoder.h"


static int sign_fn(double x){ return ((x < 0) ? (-1) : (1));};

bool LdpcDecode::layered_decoder(vector<double> channel_output ,vector<int> codeword, int * BitsinCheck , double * LLR_registers)
{
    bool decoded;

    int * var_set;
    double * old_llrs;
    double val, min1, min2;
    unsigned where, anti_matches;

    vector<double> r = channel_output;
    vector<double> llr_out = r;

    for (unsigned iter=0; iter < _numIters; iter++)
    {
        for (unsigned layer=0; layer < _m; layer++)
        {  
            for(unsigned row_num=0; row_num < _z; row_num++)   
            {   
                where = layer*z + row_num;
                
                // init 

                var_set = BitsinCheck[where];
                old_llrs = LLR_registers[where];

                num_vars = _numvars_arr[where];

                for(unsigned j=0; j < num_vars; j++)
                {
                    r[var_set[j]] = llr_out[var_set[j]] - old_llrs[j];
                }
            }

            for (unsigned row_num=0; row_num < _z; row_num++)
            {
                where = layer*z + row_num;
                
                // init 
                var_set = BitsinCheck[where];
                old_llrs = LLR_registers[where];

                num_vars = _numvars_arr[where];

                // Self Belief Removal
                for(unsigned j=0; j < num_vars; j++)
                {
                    old_llrs[j] = llr_out[var_set[j]] - old_llrs[j];     
                }

                double temp[num_vars];
                min1 = 1000.0;
                min2 = 1000.0;

                unsigned min1_idx;
                int parity = 1;

                // Min operation over llr register entries
                for(unsigned j=0; j < num_vars; j++)
                {
                    val = fabs(old_llrs[j]);

                    if(val < min2)
                    {
                        if (val < min1)
                        {
                            min2 = min1;
                            min1 = val;
                            min1_idx = j;
                        }
                        else
                        {
                            min2 = val;
                        }

                    }
                    parity *= sign_fn(old_llrs[j]);
                }

                for(unsigned j=0; j < num_vars; j++)
                {
                    temp[j] = min1;

                    if(j == min1_idx)
                    {
                        temp[j] = min2;
                    }              

                    temp[j] *= (sign_fn(old_llrs[j])*parity);
                }

                for(unsigned j=0; j < num_vars; j++)
                {
                    old_llrs[j] = temp[j];
                    r[var_set[j]] += old_llrs[j];
                }

            }

            for(unsigned i = 0; i < _N; i++)
            {
                llr_out[i] = r[i];
            }

        }

        anti_matches = 0;

        for(unsigned i = 0; i < _N; i++){if((r[i] < 0) != codeword[i]){anti_matches++;}}

        if(anti_matches == 0){break;}

    }

    decoded =  (anti_matches != 0) ? (false) : (true);
}
