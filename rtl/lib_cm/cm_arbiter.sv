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
    parameter t_sort_dir    DIR         = SORT_MAX, // Direction of the sort

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
        logic dummy_req;
        logic [DWIDTH - 1 : 0] dummy_data;
        u32 res_idx;
    } t_parb;


    function automatic t_parb get_parb();
        t_parb arb;

        case(DIR)
            SORT_MIN: begin
                arb.dummy_req   = 1'b1;
                arb.dummy_data  = '1;
                arb.res_idx     = 0;
            end
            SORT_MAX: begin
                arb.dummy_req   = 1'b0;
                arb.dummy_data  = '0;
                arb.res_idx     = DCNT - 1;
            end
        endcase

        return arb;
    endfunction


    localparam t_parb ARB = get_parb();

////////////////////////////////////////////////////////////////////////////////////////////////////
// Signals
////////////////////////////////////////////////////////////////////////////////////////////////////

    logic [DCNT - 1 : 0][DWIDTH : 0] c_data;    // Weight extended with request
    logic c_vld;

    logic [DCNT - 1 : 0][IDX_WIDTH - 1 : 0] w_idx;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Logic
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Input weight MUX
    always_comb begin : p_imux
        for(u32 i = 0; i < DCNT; i++)
            if(i_req[i] == 1'b1)
                c_data[i] = {i_req[i], i_weight[i]};
            else
                c_data[i] = {ARB.dummy_req, ARB.dummy_data};
    end

    // Sort
    assign c_vld = |i_req;

    cm_sort #(
        .DCNT(DCNT),
        .DWIDTH(DWIDTH + 1),
        .REG_CNT(REG_CNT)
    ) inst_sort (
        .i_clk(i_clk),
        .i_rst(i_rst),

        .i_vld(c_vld),
        .i_data(c_data),

        .o_vld(o_vld),
        .o_idx(w_idx),
        .o_data()
    );

    // Grant assignment
    assign o_gnt = w_idx[ARB.res_idx];

endmodule

`endif