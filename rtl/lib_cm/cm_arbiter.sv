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
    parameter u32           DCNT        = 4,        // Data count
    parameter u32           DWIDTH      = 8,        // Data width
    parameter u32           REG_CNT     = 2,        // Register count, equal to total latency
    parameter t_arb_algo    ALGO        = ARB_MAX,  // Arbitration algorithm

    localparam u32          IDX_WIDTH = sclog2(DCNT)
)(
    input logic                                 i_clk,
    input logic                                 i_rst,

    input logic [DCNT - 1 : 0]                  i_req,
    input logic [DCNT - 1 : 0][DWIDTH - 1 : 0]  i_weight,

    output logic                                o_vld,
    output logic [IDX_WIDTH - 1 : 0]            o_gnt
);

////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////

    typedef struct packed {
        logic [DWIDTH - 1 : 0] dummy;
        u32 idx;
    } t_arb;


    function automatic t_arb get_arb();
        t_arb arb;

        case(ALGO)
            ARB_MIN: begin
                arb.dummy = '1;
                arb.idx = 0;
            end
            ARB_MAX: begin
                arb.dummy = '0;
                arb.idx = DCNT - 1;
            end
        endcase

        return arb;
    endfunction


    localparam t_arb ARB = get_arb();

////////////////////////////////////////////////////////////////////////////////////////////////////
// Signals
////////////////////////////////////////////////////////////////////////////////////////////////////

    logic [DCNT - 1 : 0][DWIDTH - 1 : 0] c_weight;
    logic c_vld;
    logic [DCNT - 1 : 0][IDX_WIDTH - 1 : 0] w_idx;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Logic
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Input weight MUX
    always_comb begin : p_imux
        for(u32 i = 0; i < DCNT; i++) begin
            if(i_req[i] == 1'b1)
                c_weight[i] = i_weight[i];
            else
                c_weight[i] = ARB.dummy;
        end
    end

    // Sort
    assign c_vld = |i_req;

    cm_sort #(
        .DCNT(DCNT),
        .DWIDTH(DWIDTH),
        .REG_CNT(REG_CNT)
    ) inst_sort (
        .i_clk(i_clk),
        .i_rst(i_rst),

        .i_vld(c_vld),
        .i_data(c_weight),

        .o_vld(o_vld),
        .o_idx(w_idx),
        .o_data()
    );

    // Grant assignment
    assign o_gnt = w_idx[ARB.idx];

endmodule

`endif