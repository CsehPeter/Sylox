// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_cm
// Description  :
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __CM_SORT
`define __CM_SORT

import sys_pkg_type::*;

module cm_sort #(
    parameter u32           DCNT    = 4,
    parameter u32           DWIDTH  = 8,
    parameter u32           REG_CNT = 1
)(
    input logic                                 i_clk,
    input logic                                 i_rst,

    input logic                                 i_vld,
    input logic [DCNT - 1 : 0][DWIDTH - 1 : 0]  i_data,

    output logic                                o_vld,
    output logic [DCNT - 1 : 0][DWIDTH - 1 : 0] o_data
);
    logic [DCNT - 1 : 0][DWIDTH - 1 : 0] c_net;


    // Sum of arithmetic sequence starting from 1 to 'num' with difference of 1
    function u32 sum_arith_seq(u32 num);
        if(num % 2 == 0)
            return (num / 2) * (1 + num);
        else
            return (num / 2 + 1) * (num);
    endfunction

    // DCNT     : 2 , 4 , 8 , 16
    // STAGE    : 1 , 3 , 6 , 10
    localparam STAGE_CNT = sum_arith_seq($clog2(DCNT));


    // TODO: Function for total stage count
    // TODO: Function to see if a stage need register (stage balancer common function)

    // Bitonic sort (https://en.wikipedia.org/wiki/Bitonic_sorter)
    /*
    for (k = 2; k <= n; k *= 2) // k is doubled every iteration
        for (j = k/2; j > 0; j /= 2) // j is halved at every iteration, with truncation of fractional parts
            for (i = 0; i < n; i++)
                l = bitwiseXOR (i, j); // in C-like languages this is "i ^ j"
                if (l > i)
                    if (  (bitwiseAND (i, k) == 0) AND (arr[i] > arr[l])
                       OR (bitwiseAND (i, k) != 0) AND (arr[i] < arr[l]) )
                          swap the elements arr[i] and arr[l]
    */

endmodule

`endif