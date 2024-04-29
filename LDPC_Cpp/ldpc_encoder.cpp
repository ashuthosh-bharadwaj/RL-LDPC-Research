#include "ldpc_encoder.h"
#include <cstdlib>
#include <iostream>
#include <cmath>
#include "LDPC_H.h"

std::vector<int> LdpcCode::encode(std::vector<int> info_bits){
    // Does encoding by back substitution
    // Assumes a very specific structure on the partiy check matrix
    std::vector<int> codeword(_N, 0);
    std::copy(info_bits.begin(), info_bits.end(), codeword.begin());

    std::vector<int > parity(_M, 0);

    for(unsigned i_row = 0; i_row < _M; ++i_row) {
        for(unsigned i_col = 0; i_col < _row_mat.at(i_row).size(); ++i_col) {
            if (_row_mat.at(i_row).at(i_col) < _K)
                parity.at(i_row) += codeword.at(_row_mat.at(i_row).at(i_col));
        }
        parity.at(i_row) = (int) (parity.at(i_row) % 2);
    }

    for (unsigned i_col = 0; i_col < _Z; ++i_col) {
        for (unsigned i_row = i_col; i_row < _M; i_row = i_row + _Z) {
            codeword.at(_K + i_col) += parity.at(i_row);
        }
        codeword.at(_K + i_col) = (int ) (codeword.at(_K + i_col) % 2);
    }

    for(unsigned i_row = 0; i_row < _M; ++i_row) {
        for(unsigned i_col = 0; i_col < _row_mat.at(i_row).size(); ++i_col) {
            if ((_row_mat.at(i_row).at(i_col) >= _K) && (_row_mat.at(i_row).at(i_col) < _K + _Z))
                parity.at(i_row) += codeword.at(_row_mat.at(i_row).at(i_col));
        }
        parity.at(i_row) = (int) (parity.at(i_row) % 2);
    }


    for (unsigned i_col = _K + _Z; i_col < _N; i_col = i_col + _Z  ) {
        for (unsigned i_row = 0; i_row < _Z; ++i_row) {
            codeword.at(i_col + i_row) = parity.at(i_col + i_row - _K - _Z);
            parity.at(i_col + i_row - _K ) = (int) (( parity.at(i_col + i_row - _K) + parity.at(i_col + i_row - _K - _Z)) %2);
         }
    }

    return codeword;

}


void LdpcCode::generate_compact_rep() {

    _column_mat.resize(_N);
    _row_mat.resize(_M);

    for (unsigned i_col = 0; i_col < _N; ++i_col)
        _column_mat.at(i_col).resize(0);

    for (unsigned i_row = 0; i_row < _M; ++ i_row)
        _row_mat.at(i_row).resize(0);


    for (unsigned i_col = 0; i_col < _N; ++i_col) {
        for (unsigned i_row = 0; i_row < _M; ++ i_row) {
            if (_H_mat.at(i_col).at(i_row) == 1 ) {
                _column_mat.at(i_col).push_back(i_row);
                _row_mat.at(i_row).push_back(i_col);
            }
        }
    }
}

bool LdpcCode::check_codeword(std::vector<int> decoded_cw) {

    bool check = true;
    for ( unsigned i_check = 0; i_check < _M; ++i_check ) {
        int  c = 0;
        for (unsigned i_col_index = 0; i_col_index < _row_mat.at(i_check).size(); ++i_col_index ){
            unsigned i_col = _row_mat.at(i_check).at(i_col_index);
            c  = c + decoded_cw.at(i_col);
        }
        if ( (c % 2) == 1 ) {
            check = false;
            break;
        }
    }

    return check;

}

void LdpcCode::load_wifi_ldpc(unsigned block_length) {

    switch (block_length)
    {
        case 1944:
            
            _N = block_length;
            _Z = 81;
            _K = _N/2;
            _max_non_null = 8;
            _h_pointer = &LDPCBASE_H::H_1944_1_2[0][0];
            
            break;


        case 520:
            _N = block_length;
            _Z = 10;
            _K = (unsigned) (_N*100/520);
            _max_non_null = 10;
            _h_pointer = &LDPCBASE_H::H_520_5_26[0][0];    
            break;    
        

        default:
            break;
    }

    _M = _N - _K;

    std::vector<std::vector<int>> baseH(_N/_Z);

    for (unsigned i_col = 0; i_col < _N/_Z ; ++i_col )
        baseH.at(i_col).resize(_M/_Z );

    for (unsigned i_col = 0; i_col < _N/_Z ; ++i_col ) {
        for (unsigned i_row = 0; i_row < _M/_Z ; ++i_row ) {
            baseH.at(i_col).at(i_row) = * ( _h_pointer + i_col  + i_row * _N/_Z );
        }
    }

    lifted_ldpc(baseH);
}

void LdpcCode::lifted_ldpc(std::vector<std::vector<int>> baseH){

    _H_mat.resize(_N);

    for (unsigned j = 0; j < _N ; ++j ) {
        _H_mat.at(j).resize(_M);
    }

    for (unsigned i_row = 0; i_row < _M; ++i_row ) {
        for (unsigned i_col = 0; i_col < _N; ++i_col)
            _H_mat.at(i_col).at(i_row) = 0;
    }

    for (unsigned i_base_row = 0; i_base_row < baseH.at(0).size(); ++i_base_row ) {
        for (unsigned i_base_col = 0; i_base_col < baseH.size(); ++i_base_col ){
            if ( baseH.at(i_base_col).at(i_base_row) >= 0 ) {
                for (unsigned i_lift = 0; i_lift < _Z ; ++i_lift ) {
                    _H_mat.at(_Z  * i_base_col + ( (i_lift + baseH.at(i_base_col).at(i_base_row)) % _Z ) ).at(_Z  * i_base_row + i_lift) = 1;
                }
            }
        }
    }

    generate_compact_rep();
}

static std::vector<int> mul_shift(std::vector<int> x, int k){
    unsigned len = x.size();
    std::vector<int> y(len,0); 

    if(k==-1)
    {
        for(unsigned i=0; i < len; i++)
        {
            y[i] = 0;
        }

        return y;
    }
    else 
    {
        for(unsigned i=0; i < len; i++)
        {
            y[i] = x[(i+k)%len];
        }

        return y;
    }
}


std::vector<int> LdpcCode::encode(std::vector<int> info_bits, int * hptr){

    // B: base matrix
    // z: expansion factor
    // msg: message vector, length = (#cols(B)-#rows(B))*z
    // cword: codeword vector, length = #cols(B)*z

    unsigned z = _Z;
    unsigned m = (unsigned) _M/z;
    unsigned n = (unsigned) _N/z;

    std::vector<int> that_old(z,0);
    std::vector<int> that(z,0);

    std::vector<int> codeword(_N, 0); 

    for(unsigned i=0; i < (n-m)*z; i++)
    {
        codeword[i] = info_bits[i];
    }

    for(unsigned i= (n-m)*z; i < n*z; i++)
    {
        codeword[i] = 0;
    }


    std::vector<int> temp(z,0);

    for(unsigned i =0; i < z; i++)
    {
        temp[i] = 0;
    }

    // --------------------------------------------------------------------------
    for(unsigned i =0; i < 4; i++)
    {

        for(unsigned j = 0; j < n-m; j++)
        {       
            
            for(unsigned idx = 0; idx < z;idx++)
            {
                that_old[idx] = info_bits[j*z + idx];
            }

            that = mul_shift(that_old, *(hptr + i*(n) + j));
            

            //mul_sh(msg((j-1)*z+1:j*z),B(i,j));
            //j = 1:n-m %message columns
            for(unsigned idx = 0; idx < z; idx++)
            {
                temp[idx] = (temp[idx] + that[idx])%2;
            }

        }
    }

    // --------------------------------------------------------------------------

    int p1_sh;

    if (*(hptr + 1*(n) + (n-m)) == -1)
    {
        p1_sh = *(hptr + 2*n + (n-m));
    }
    else
    {
        p1_sh = *(hptr + 1*n + (n-m));
    }


    // --------------------------------------------------------------------------

    std::vector<int> rishglasses = mul_shift(temp,z-p1_sh);

    for(unsigned i = 0; i < z; i++)
    {
        codeword[(n-m)*z+i] = rishglasses[i];
    }


    // --------------------------------------------------------------------------


    for(unsigned i=0; i < 3;i++)
    {

        for(unsigned idx =0; idx < z; idx++)
        {
            temp[idx] = 0;
        }

        for(unsigned j=0; j < n-m+i+1; j++)
        {   

            for(unsigned idx=0; idx < z; idx++)
            {
                that_old[idx] = codeword[(j)*z + idx];
            }

            that = mul_shift(that_old, *(hptr + i*(n) + j));

            for(unsigned idx=0; idx < z; idx++)
            {
                temp[idx] = (temp[idx] + that[idx])%2;
            }

            for(unsigned idx=0; idx < z; idx++)
            {
                codeword[(n-m+i+1)*z + idx] = temp[idx]; 
            }
        }
    }

    // --------------------------------------------------------------------------
    for(unsigned i=4; i < m; i++)
    {
        for(unsigned idx=0; idx < z; idx++)
        {
            temp[idx] = 0;
        }
        
        for(unsigned j=0; j < n-m+4; j++)
        {
            for(unsigned idx=0; idx < z; idx++)
            {
                that_old[idx] = codeword[(j)*z + idx];
            }

            that = mul_shift(that_old, *(hptr + i*(n) + j));

            for(unsigned idx=0; idx < z; idx++)
            {
                temp[idx] = (temp[idx] + that[idx])%2;
            }

            for(unsigned idx=0; idx < z; idx++)
            {
                codeword[(n-m+i)*z + idx] = temp[idx]; 
            }
        }
    }
    // --------------------------------------------------------------------------

    return codeword;
}

void LdpcCode::Create_BinC(int * BnC){

    unsigned M = _M;
    unsigned Z = _Z;
    unsigned max_non_null = _max_non_null;
    unsigned N = _N;

    int * h_pointer = _h_pointer;

    int BitsinCheck[M][max_non_null];
    
    for(int i=0; i < M; i++)
    {
        for(int j=0; j < max_non_null; j++)
        {
            BitsinCheck[i][j] = -1;
        }
    }

    int SubMatrixVal, idx, SubMatrixRow;

    for(int row_num = 0; row_num < M; row_num++)
    {
        SubMatrixRow = (row_num/Z);
        idx = 0;
        
        for(int col = 0; col < (N/Z); col++)
        {   
            // SubMatrixVal = SubMatrix[SubMatrixRow][col];
            SubMatrixVal = *(h_pointer + SubMatrixRow*(max_non_null) + col);

            if(SubMatrixVal != -1)
            {
                BitsinCheck[row_num][idx] = Z*(col) + ((row_num + SubMatrixVal)%Z);
                idx++;
            }
        }
    }


    std::copy(&(BitsinCheck[0][0]),&(BitsinCheck[0][0]) + M*max_non_null, BnC);
}