// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_ds
// Description  :
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __DS_FIFO
`define __DS_FIFO

import cm_pkg_type::*;
import cm_pkg_fn::*;

import ds_pkg::*;

module ds_fifo #(
    parameter type          DTYPE       = logic [7 : 0],
    parameter u32           CAPACITY    = 8,
    parameter t_fifo_arch   ARCH        = FIFO_ARCH_RAM
)(
    input logic     i_clk,
    input logic     i_rst,

    ds_if.slv       if_wr,
    cm_if_lvl.mst   if_wr_lvl,

    ds_if.mst       if_rd,
    cm_if_lvl.mst   if_rd_lvl
);

////////////////////////////////////////////////////////////////////////////////////////////////////
// Signals
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Memory
    DTYPE q_mem [CAPACITY];

    // Levels
    logic                                   q_full;
    logic [sclog2(CAPACITY + 1) - 1 : 0]    q_ewc;
    logic                                   q_ewc_gte;

    logic                                   q_empty;
    logic [sclog2(CAPACITY + 1) - 1 : 0]    q_wc;
    logic                                   q_wc_gte;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Data Path
////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        if(CAPACITY == 0) begin : gen_bypass_dp
            assign if_rd.data = if_wr.data;

        end else begin : gen_dp
            case(ARCH)

                FIFO_ARCH_RAM: begin
                    // Pointers
                    logic [$clog2(CAPACITY) - 1 : 0] q_wr_ptr;
                    logic [$clog2(CAPACITY) - 1 : 0] q_rd_ptr;

                    always_ff @ (posedge i_clk) begin : p_ptrs
                        if(i_rst) begin
                            q_wr_ptr <= '0;
                            q_rd_ptr <= '0;
                        end else begin
                            if(if_wr.xfer)
                                q_wr_ptr <= `WRAP(q_wr_ptr, 1, 0, CAPACITY - 1);       // Increment with wrap-around

                            if(if_rd.xfer)
                                q_rd_ptr <= `WRAP(q_rd_ptr, 1, 0, CAPACITY - 1);       // Increment with wrap-around
                        end
                    end

                    // Memory access
                    always_ff @ (posedge i_clk) begin : p_mem
                        if(if_wr.xfer)
                            q_mem[q_wr_ptr] <= if_wr.data;
                    end

                    assign if_rd.data = q_mem[q_rd_ptr];
                end


                FIFO_ARCH_SHR: begin
                    always_ff @ (posedge i_clk) begin : p_mem
                        for(u32 i = 0; i < CAPACITY - 1; i++)

                            case({if_rd.xfer, if_wr.xfer})
                                2'b01:  // WR only
                                    if(i == q_wc)
                                        q_mem[i] <= if_wr.data;

                                2'b10:  // RD only
                                    q_mem[i] <= q_mem[i + 1];

                                2'b11:  // Both
                                    if(i == q_wc)
                                        q_mem[i] <= if_wr.data;
                                    else
                                        q_mem[i] <= q_mem[i + 1];
                            endcase
                    end

                    assign if_rd.data = q_mem[0];

                end
            endcase
        end
    endgenerate

////////////////////////////////////////////////////////////////////////////////////////////////////
// Handshake
////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        if(CAPACITY == 0) begin : gen_bypass_hs
            assign if_wr.rdy = if_rd.rdy;
            assign if_rd.vld = if_wr.vld;

        end else begin : gen_hs

            always_ff @ (posedge i_clk) begin : proc_hs
                if(i_rst) begin
                    if_wr.rdy <= 1'b1;
                    if_rd.vld <= 1'b0;
                end else begin

                    // Write
                    if(q_wc + if_wr.xfer - if_rd.xfer == CAPACITY)
                        if_wr.rdy <= 1'b0;
                    else
                        if_wr.rdy <= 1'b1;


                    // Read
                    if(q_wc + if_wr.xfer - if_rd.xfer == '0)
                        if_rd.vld <= 1'b0;
                    else
                        if_rd.vld <= 1'b1;
                end
            end

        end
    endgenerate

////////////////////////////////////////////////////////////////////////////////////////////////////
// Levels
////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        if(CAPACITY == 0) begin : gen_bypass_lvl
            assign if_wr_lvl.lim        = 1'b0;
            assign if_wr_lvl.lvl        = '0;
            assign if_wr_lvl.lvl_gte    = 1'b0;

            assign if_rd_lvl.lim        = 1'b0;
            assign if_rd_lvl.lvl        = '0;
            assign if_rd_lvl.lvl_gte    = 1'b0;

        end else begin : gen_lvl

            always_ff @ (posedge i_clk) begin : proc_lvl
                if(i_rst) begin
                    q_full      <= 1'b0;
                    q_ewc       <= '0;
                    q_ewc_gte   <= 1'b1;

                    q_empty     <= 1'b0;
                    q_wc        <= '0;
                    q_wc_gte    <= if_rd_lvl.lvl_thr == '0;
                end else begin
                    case({if_rd.xfer, if_wr.xfer})

                        // Equal amount of WR and RD
                        default: begin
                            q_ewc_gte   <= q_ewc >= if_wr_lvl.lvl_thr;
                            q_wc_gte    <= q_wc >= if_rd_lvl.lvl_thr;
                        end

                        // WR only
                        2'b01: begin
                            q_full      <= (q_ewc - 1'b1) == '0;
                            q_ewc       <= (q_ewc - 1'b1);
                            q_ewc_gte   <= (q_ewc - 1'b1) >= if_wr_lvl.lvl_thr;

                            q_empty     <= 1'b0;
                            q_wc        <= (q_wc + 1'b1);
                            q_wc_gte    <= (q_wc + 1'b1) >= if_rd_lvl.lvl_thr;
                        end

                        // RD only
                        2'b10: begin
                            q_full      <= 1'b0;
                            q_ewc       <= (q_ewc + 1'b1);
                            q_ewc_gte   <= (q_ewc + 1'b1) >= if_wr_lvl.lvl_thr;

                            q_empty     <= (q_wc - 1'b1) == '0;
                            q_wc        <= (q_wc - 1'b1);
                            q_wc_gte    <= (q_wc - 1'b1) >= if_rd_lvl.lvl_thr;
                        end
                    endcase
                end
            end

            // Write side
            assign if_wr_lvl.lim        = q_full;
            assign if_wr_lvl.lvl        = q_ewc;
            assign if_wr_lvl.lvl_gte    = q_ewc_gte;

            // Read side
            assign if_rd_lvl.lim        = q_empty;
            assign if_rd_lvl.lvl        = q_wc;
            assign if_rd_lvl.lvl_gte    = q_wc_gte;

        end
    endgenerate

endmodule

`endif