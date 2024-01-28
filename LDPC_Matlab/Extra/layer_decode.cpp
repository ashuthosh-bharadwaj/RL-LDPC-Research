#include "mex.hpp"
#include "mexAdapter.hpp"
#include <stdio.h>
#include <iostream>

using namespace matlab::data;
using matlab::mex::ArgumentList;

class MexFunction : public matlab::mex::Function {//Base class for C++ MEX functions
public:
    void operator()(ArgumentList outputs, ArgumentList inputs){//Container for inputs and outputs from MEX
    ArrayFactory factory; //to create output arrays.

    TypedArray<double> LLR = inputs[0]; 

    TypedArray<bool> CDW = inputs[1];
    TypedArray<uint8_t> LDPC_details = inputs[2];

    int m = LDPC_details[0];
    int z = LDPC_details[1];

    TypedArray<uint32_t> Decoder_details = inputs[3];


    int numIters = Decoder_details[0];
    int numTrials = Decoder_details[1];

    int where, N_errors = 0;

    CellArray BitsinCheck = inputs[4]; 
    CellArray LLR_registers = inputs[5];
    const CellArray LLR_init = LLR_registers;

    TypedArray<double> r = inputs[6];
    TypedArray<bool> codeword = inputs[7];

    int anti_matches;

    ArrayDimensions dims = LLR.getDimensions();
    int num_llrs = dims[1];


    for(int trial=0; trial < numTrials; trial++)
    {      
        LLR_registers = LLR_init;

        for(int idx=0; idx < num_llrs; idx++)
        {
            r[idx] = LLR[trial][idx];
            codeword[idx] = CDW[trial][idx];
        }

        auto llr_out = r;

        for (int iter=0; iter < numIters; iter++)
        {

            for (int layer=0; layer < m; layer++)
            {
                
                for(int row_num=0; row_num < z; row_num++)   
                {   
                    where = layer*z + row_num;
                    // init 
                    TypedArray<double> var_set = BitsinCheck[where];
                    TypedArray<double> old_llrs = LLR_registers[where];
                    int num_vars = var_set.getNumberOfElements(); 

                    for(int j=0; j < num_vars; j++)
                    {
                        r[var_set[j]-1] = llr_out[var_set[j]-1] - old_llrs[j];
                    }
                }

                for (int row_num=0; row_num < z; row_num++)
                {
                    where = layer*z + row_num;
                    
                    // init 
                    TypedArray<double> var_set = BitsinCheck[where];
                    TypedArrayRef<double> old_llrs = LLR_registers[where];

                    int num_vars = var_set.getNumberOfElements();

                    // Self Belief Removal
                    for(int j=0; j < num_vars; j++)
                    {
                        old_llrs[j] = llr_out[var_set[j]-1] - old_llrs[j];     
                    }
                    
                    double temp[num_vars];
                    double min1 = 1000.0;
                    double min2 = 1000.0;

                    int min1_idx, parity = 1;
                    double val;

                    // Min operation over llr register entries
                    for(int j=0; j < num_vars; j++)
                    {
                        val = std::fabs(old_llrs[j]);

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

                    for(int j=0; j < num_vars; j++)
                    {
                        temp[j] = min1;

                        if(j == min1_idx)
                        {
                            temp[j] = min2;
                        }              

                        temp[j] *= (sign_fn(old_llrs[j])*parity);
                    }

                    for(int j=0; j < num_vars; j++)
                    {
                        old_llrs[j] = temp[j];
                        r[var_set[j]-1] += old_llrs[j];
                    }

                }

                for(int i = 0; i < num_llrs; i++)
                {
                    llr_out[i] = r[i];
                }

            }

            anti_matches = 0;

            for(int i = 0; i < num_llrs; i++){if((r[i] < 0) != codeword[i]){anti_matches++;}}

            if(anti_matches == 0){break;}

        }

        if (anti_matches != 0)
        {   
            N_errors++;
        }

    }

    outputs[0] = factory.createScalar<double>(N_errors);

    }

    // Sign function such that (-inf, 0) -> -1, [0, inf) -> 1    
    int sign_fn(double x){
        if(x < 0)
        {
            return -1;
        }
        else
        {
            return 1;
        }
    }

};


    // Outline of the algorithm;

    // for iter = 1:numIters

    //     for layer = 1:numSubMatrixRows

    //         for row_num = 1:z    
    //             r(BitsinCheck{(layer-1)*z + row_num}) = llr_out(BitsinCheck{(layer-1)*z + row_num}) - LLR_registers{(layer-1)*z + row_num}';
    //         end
                
    //         for row_num = 1:z    
    //             LLR_registers{(layer-1)*z + row_num} = llr_out(BitsinCheck{(layer-1)*z + row_num})' - LLR_registers{(layer-1)*z + row_num};
    //             LLR_registers{(layer-1)*z + row_num} = Min(LLR_registers{(layer-1)*z + row_num});
    //             r(BitsinCheck{(layer-1)*z + row_num}) = r(BitsinCheck{(layer-1)*z + row_num}) + LLR_registers{(layer-1)*z + row_num}';
    //         end              
    //         llr_out = r;
    //     end

    //     if all((r<0) == codeword)
    //         break
    //     end

    // end



/*Extra code bits for help:

    // TypedArray<double> const newArray = BitsinCheck[0][0];
    // for (auto e : some) 
    // {
    //     std::cout << e << std::endl;
    // } 

    // std::cout<<"input[5] is LLR_registers and the first of its size: "<<LLR_registers[0]<<std::endl;

    // TypedArray<double> old_llrs = LLR_registers[0];
    // for (auto u: old_llrs)
    // {
    //     u += 5;
    // }



    // int nn = LLR_registers[0].getNumberOfElements();
    // std::cout<<"Num elements in LLR_registers"<<nn<<std::endl;

    // for (int jj = 0; jj < nn; jj++)
    // {   
    //     LLR_registers[jj][0] += 5;
    // }

    // TypedArray<double> old_llrs2 = LLR_registers[0];
    
    // for (auto u: old_llrs2)
    // {
    //     std::cout<<u<<", ";
    // }

    // TypedArrayRef<double> doubleArray = BitsinCheck[1][0];




    std::cout<<"temp array after min() operation over old_llrs"<<std::endl;
    for(auto elem: temp)
    {
        std::cout<<elem<<std::endl;
    }
*/