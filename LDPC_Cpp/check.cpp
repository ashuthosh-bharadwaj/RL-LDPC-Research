// #include<iostream>
// #include "LDPC_H.h"

// using namespace std;

// int main(){

//     int locs[972][8];

//     for(int i=0; i < 972; i++)
//     {
//         for(int j=0; j < 8; j++)
//         {
//             locs[i][j] = -1;
//         }
//     }

//     int z = 81;  
//     int SubMatrixVal, idx, SubMatrixRow;

//     for(int row_num = 0; row_num < 972; row_num++)
//     {
//         SubMatrixRow = (row_num/z);
//         idx = 0;
        
//         for(int col = 0; col < 24; col++)
//         {   
//             SubMatrixVal = LDPCBASE_H::H_1944_1_2[SubMatrixRow][col];

//             if(SubMatrixVal != -1)
//             {
//                 locs[row_num][idx] = z*(col) + ((row_num + SubMatrixVal)%z);
//                 idx++;
//             }
//         }
//     }



// }

