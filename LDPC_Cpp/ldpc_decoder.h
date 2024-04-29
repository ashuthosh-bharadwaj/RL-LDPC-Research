#include <vector>


class LdpcDecode
{
    private:

    unsigned _numIters;
    int * _numvars_arr;

    public:

    LdpcDecode(unsigned numIters, unsigned code_len, unsigned numlayers, unsigned exp_factor, int * numvars_arr)
    {   
        _N = code_len;
        _m = numlayers;
        _z = exp_factor; 

        _numIters = numIters;
        _numvars_arr = numvars_arr;
    }

    bool layered_decoder(std::vector<double> channel_output ,std::vector<int> codeword, int * BitsinCheck , double * LLR_registers);

    // bool flooding_decoder(std::vector<double> channel_output ,std::vector<int> codeword, int * BitsinCheck , double * LLR_registers);
}






























#endif