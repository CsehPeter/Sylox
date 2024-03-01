// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_ds
// Description  :
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __DS_ICON
`define __DS_ICON

import sys_pkg_type::*;
import sys_pkg_fn::*;

import ds_pkg::*;

module ds_icon #(
    parameter u32           SLV_CNT                             = 4,
    parameter u32           MST_CNT                             = 4,
    parameter t_icon_arch   ARCH                                = ICON_ARCH_SERIAL,
    parameter type          DTYPE                               = logic [7 : 0],

    parameter u32           SLV_FIFO_CAPACITY [SLV_CNT - 1 : 0] = '{8, 8, 8, 8},
    parameter u32           MID_FIFO_CAPACITY                   = 2,
    parameter u32           MST_FIFO_CAPACITY [MST_CNT - 1 : 0] = '{8, 8, 8, 8},

    localparam u32          SLV_IDX_WIDTH                       = sclog2(SLV_CNT),
    localparam u32          MST_IDX_WIDTH                       = sclog2(MST_CNT)
)(
    input logic                         i_clk,
    input logic                         i_rst,

    // Slave
    input logic [MST_IDX_WIDTH - 1 : 0] i_slv_dst [SLV_CNT - 1 : 0],
    ds_if.slv                           if_slv [SLV_CNT - 1 : 0],

    // Master
    input logic [SLV_IDX_WIDTH - 1 : 0] i_mst_dst [MST_CNT - 1 : 0],
    ds_if.mst                           if_mst [MST_CNT - 1 : 0]
);

////////////////////////////////////////////////////////////////////////////////////////////////////
// Constants
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Number of interfaces and FIFOs in the middle layer
    localparam MID_CNT = ARCH == ICON_ARCH_SERIAL ? 1 : SLV_CNT * MST_CNT;

    localparam MUX_CNT = ARCH == ICON_ARCH_SERIAL ? 1 : MST_CNT;
    localparam DEMUX_CNT = ARCH == ICON_ARCH_SERIAL ? 1 : SLV_CNT;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Types
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Routing
    typedef struct {
        logic [SLV_IDX_WIDTH - 1 : 0]   slv;
        logic [MST_IDX_WIDTH - 1 : 0]   mst;
    } t_route;

    // Data extended with routing
    typedef struct {
        t_route route;
        DTYPE   data;
    } t_ext_data;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Interfaces
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Slave
    ds_if #(
        .DTYPE(t_ext_data),
        .FC(FC_BI)
    ) if_slv_wr [SLV_CNT - 1] ();

    ds_if #(
        .DTYPE(t_ext_data),
        .FC(FC_BI)
    ) if_slv_rd [SLV_CNT - 1] ();

    // Middle
    ds_if #(
        .DTYPE(t_ext_data),
        .FC(FC_BI)
    ) if_mid_wr [MID_CNT - 1] ();

    ds_if #(
        .DTYPE(t_ext_data),
        .FC(FC_BI)
    ) if_mid_rd [MID_CNT - 1] ();

    // Master
    ds_if #(
        .DTYPE(t_ext_data),
        .FC(FC_BI)
    ) if_mst_wr [MST_CNT - 1] ();

    ds_if #(
        .DTYPE(t_ext_data),
        .FC(FC_BI)
    ) if_mst_rd [MST_CNT - 1] ();


    /*
    cm_if_lvl #(.CAPACITY(DUT_CFG[g].capacity)
                ) if_wr_lvl ();
    */

////////////////////////////////////////////////////////////////////////////////////////////////////
// Signals
////////////////////////////////////////////////////////////////////////////////////////////////////

    logic [MUX_CNT - 1 : 0][SLV_IDX_WIDTH - 1 : 0] w_mux_sel;
    logic [DEMUX_CNT - 1 : 0][MST_IDX_WIDTH - 1 : 0] w_demux_sel;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Slave
////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        for(genvar i = 0; i < SLV_CNT; i++) begin

            // Data extension with routing
            t_ext_data  ext_data;
            assign ext_data.route.slv = i;
            assign ext_data.route.mst = i_slv_dst[i];
            assign ext_data.data = if_slv[i].data;

            assign if_slv_wr[i].vld = if_slv[i].vld;
            assign if_slv[i].rdy = if_slv_wr[i].rdy;
            assign if_slv_wr[i].data = if_slv[i].ext_data;

            // FIFO
            ds_fifo #(
                .CAPACITY   (SLV_FIFO_CAPACITY[i]),
                .DTYPE      (t_ext_data),
                .ARCH       (FIFO_ARCH_RAM)
            ) inst_ds_fifo (
                .i_clk      (i_clk),
                .i_rst      (i_rst),

                .if_wr      (if_slv_wr[i]),
                .if_wr_lvl  (),

                .if_rd      (if_slv_rd[i]),
                .if_rd_lvl  ()
            );
        end
    endgenerate

////////////////////////////////////////////////////////////////////////////////////////////////////
// Middle
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Write - MUX / DEMUX
    generate
        case(ARCH)
            ICON_ARCH_SERIAL: begin : g_mux
                always_comb begin : p_mux
                    if_mid_wr[0].vld = if_slv_rd[w_mux_sel[0]].vld;
                    if_slv_rd[w_mux_sel[0]].rdy = if_mid_wr[0].rdy;
                    if_mid_wr[0].data = if_slv_rd[w_mux_sel[0]].data;
                end
            end

            ICON_ARCH_PARALLEL: begin : g_demux
                for(genvar s = 0; s < SLV_CNT; s++) begin

                    logic [MST_IDX_WIDTH - 1 : 0] mst_sel;
                    assign mst_sel = if_slv_rd[s].data.route.mst;

                    // Valid
                    for(genvar m = 0; m < MST_CNT; m++)
                        always_comb
                            if(mst_sel == m)
                                if_mid_wr[s * SLV_CNT + m].vld = 1'b1;
                            else
                                if_mid_wr[s * SLV_CNT + m].vld = 1'b0;

                    // Ready
                    always_comb
                        if_slv_rd[s].rdy = if_mid_wr[mst_sel].rdy;

                    // Data
                    for(genvar m = 0; m < MST_CNT; m++)
                        assign if_mid_wr[s * SLV_CNT + m] = if_slv_rd[s].data;
                end
            end
        endcase
    endgenerate

    // FIFO
    generate
        for(genvar i = 0; i < MID_CNT; i++) begin
            ds_fifo #(
                .CAPACITY   (MID_FIFO_CAPACITY),
                .DTYPE      (t_ext_data),
                .ARCH       (FIFO_ARCH_SHR)
            ) inst_ds_fifo (
                .i_clk      (i_clk),
                .i_rst      (i_rst),

                .if_wr      (if_mid_wr[i]),
                .if_wr_lvl  (),

                .if_rd      (if_mid_rd[i]),
                .if_rd_lvl  ()
            );
        end
    endgenerate

endmodule

`endif