#include <vector>

class LdpcCode {

private:

    std::vector<std::vector<int>> _H_mat;
    unsigned _N;
    unsigned _K;
    unsigned _M;
    unsigned _Z;
    unsigned _max_non_null;

    // int BitsinCheck[_M][_max_non_null];

    int * _h_pointer;

    std::vector<std::vector<unsigned>> _column_mat;
    std::vector<std::vector<unsigned>> _row_mat;

    void generate_compact_rep();

    void lifted_ldpc(std::vector<std::vector<int>> baseH);

public:

    bool check_codeword(std::vector<int>);

    void load_wifi_ldpc(unsigned block_length);

    unsigned get_info_length() {return _K;};
    unsigned get_expfactor(){return _Z;};
    unsigned get_submatrow(){return _M/_Z;};
    unsigned get_submatcol(){return _N/_Z;};

    unsigned get_matrow(){return _M;};
    unsigned get_matcol(){return _N;};
    unsigned get_max_nonnull(){return _max_non_null;};
    int * get_h_pointer(){return _h_pointer;};

    LdpcCode(unsigned block_length, unsigned info_length): _N(block_length), _K(info_length), _Z(0){
        _M = _N - _K;
        _H_mat.resize(_N);
        for (unsigned j = 0; j < _N ; ++j ) {
            _H_mat.at(j).resize(_M); 
        }
    };

    std::vector<int> encode(std::vector<int> info_bits);
    std::vector<int> encode(std::vector<int> info_bits, int * hptr);
    void Create_BinC(int * BnC);
};
