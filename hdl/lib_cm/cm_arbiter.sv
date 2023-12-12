// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_cm
// Description  :
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __CM_ARBITER
`define __CM_ARBITER

import sys_pkg_type::*;
import cm_pkg::*;

module cm_arbiter #(
    parameter u32           CH_CNT      = 2,
    parameter u32           WEIGHT_BITS = 8,
    parameter t_arb_algo    ALGO        = ARB_MIN
)(
    input logic     i_clk,
    input logic     i_rst,

    logic [CH_CNT - 1 : 0]                      i_req,
    logic [CH_CNT - 1 : 0][WEIGHT_BITS - 1 : 0] i_weight,

    logic [CH_CNT - 1 : 0]                      o_gnt
);

    generate
        case(ALGO)
            ARB_MIN: begin

            end
            ARB_MAX: begin

            end
        endcase
    endgenerate

endmodule

`endif