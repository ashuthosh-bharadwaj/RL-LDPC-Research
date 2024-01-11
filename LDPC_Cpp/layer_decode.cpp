#include "mex.hpp"
#include "mexAdapter.hpp"
#include <stdio.h>
#include <iostream>

using namespace matlab::data;
using matlab::mex::ArgumentList;

class MexFunction : public matlab::mex::Function {//Base class for C++ MEX functions
public:
    void operator()(ArgumentList outputs, ArgumentList inputs) {//Container for inputs and outputs from MEX
    ArrayFactory factory; //to create output arrays.

    TypedArray<double> llr_out = inputs[0];
    TypedArray<bool> codeword = inputs[1];
    TypedArray<uint8_t> LDPC_details = inputs[2];

    int numIters = inputs[3][0];
    int where;
    const CellArray BitsinCheck = inputs[4]; 
    const CellArray LLR_registers = inputs[5];

    int m = LDPC_details[0];
    int z = LDPC_details[1];

    TypedArray<double> some = BitsinCheck[0];

    std::cout<<"Hello MEX here!"<<std::endl;
    std::cout<<"input[0] is llr_out and its size: "<<llr_out[0]<<std::endl;
    std::cout<<"input[1] is codeword and its size: "<<codeword[0]<<std::endl;
    std::cout<<"input[2] is LDPC_details and its size: "<<(sizeof(LDPC_details))<<std::endl;
    std::cout<<"input[3] is numIters and its size: "<<(sizeof(numIters))<<std::endl;
    std::cout<<"input[4] is BitsinCheck and the first of its size: "<<some[0]<<std::endl;

    // std::cout<<"input[5] is LLR_registers and its size: "<<(sizeof())<<std::endl;


    auto r = llr_out; // intermediate llrs
    bool decode_result; // Did the decoder get to the codeword?

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
                // TypedArray<double> var_set = BitsinCheck[where];
                // TypedArray<double> old_llrs = LLR_registers[where];
                int num_vars = var_set.getNumberOfElements();

                for(int j=0; j < num_vars; j++)
                {
                    old_llrs
                }

            }   
    //             LLR_registers{(layer-1)*z + row_num} = llr_out(BitsinCheck{(layer-1)*z + row_num})' - LLR_registers{(layer-1)*z + row_num};
    //             LLR_registers{(layer-1)*z + row_num} = Min(LLR_registers{(layer-1)*z + row_num});
    //             r(BitsinCheck{(layer-1)*z + row_num}) = r(BitsinCheck{(layer-1)*z + row_num}) + LLR_registers{(layer-1)*z + row_num}';
    //         end              

            

        }
    }
        
    // output[0] = factory.CreateScalar(decode_result);

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