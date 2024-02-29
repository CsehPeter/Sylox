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

    typedef struct {
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
// Logic
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Input weight MUX
    logic [DCNT - 1 : 0][DWIDTH - 1 : 0] c_weight;

    always_comb begin : p_imux
        for(u32 i = 0; i < DCNT; i++) begin
            if(i_req[i] == 1'b1)
                c_weight[i] = i_weight[i];
            else
                c_weight[i] = ARB.dummy;
        end
    end

    // Input index assignment
    logic [DCNT - 1 : 0][IDX_WIDTH - 1 : 0] w_idx;
    generate
        for(genvar i = 0; i < DCNT; i++) begin
            assign w_idx[i] = i;
        end
    endgenerate

    // Weight extension with index
    localparam u32 EXT_DWIDTH = DWIDTH + IDX_WIDTH;
    logic [DCNT - 1 : 0][EXT_DWIDTH - 1 : 0] c_data;

    generate
        for(genvar i = 0; i < DCNT; i++) begin
            assign c_data[i] = {c_weight[i], w_idx[i]};
        end
    endgenerate

    // Sort
    logic c_vld;
    assign c_vld = |i_req;
    logic [DCNT - 1 : 0][EXT_DWIDTH - 1 : 0] w_ord_data;

    cm_sort #(
        .DCNT(DCNT),
        .DWIDTH(EXT_DWIDTH),
        .REG_CNT(REG_CNT)
    ) inst_sort (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_vld(c_vld),
        .i_data(c_data),
        .o_vld(o_vld),
        .o_data(w_ord_data)
    );

    // Grant slice
    assign o_gnt = w_ord_data[ARB.idx][IDX_WIDTH - 1 : 0];

endmodule

`endif