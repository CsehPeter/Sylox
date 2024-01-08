// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : verif_sim
// Description  :
////////////////////////////////////////////////////////////////////////////////////////////////////

import sys_pkg_type::*;
import ds_pkg::*;

module sim_ds ();

////////////////////////////////////////////////////////////////////////////////////////////////////
//  Types & Constants
////////////////////////////////////////////////////////////////////////////////////////////////////

    localparam type DTYPE       = logic [7 : 0];
    localparam u32  CFG_CNT     = 6;

    // Config type
    typedef struct packed {
        u32             capacity;
        t_fc            fc;
        t_fifo_arch     arch;
    } t_fifo_cfg;

////////////////////////////////////////////////////////////////////////////////////////////////////
//  DUT Config
////////////////////////////////////////////////////////////////////////////////////////////////////

    localparam t_fifo_cfg DUT_CFG [CFG_CNT - 1 : 0] = '{
        '{0, FC_BI, FIFO_ARCH_SHR},
        '{1, FC_BI, FIFO_ARCH_SHR},
        '{8, FC_BI, FIFO_ARCH_SHR},
        '{8, FC_BI, FIFO_ARCH_RAM},
        '{8, FC_UNI, FIFO_ARCH_RAM},
        '{8, FC_NO, FIFO_ARCH_RAM}
    };

////////////////////////////////////////////////////////////////////////////////////////////////////
// Initialize (Clock & Reset)
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Clock
    logic clk = 1'b0;
    always #5 clk = ~clk;

    // Reset
    logic rst = 1'b0;

    task rst_dut;
        begin
            rst <= 1'b1;
            repeat(2) @ (posedge clk);
            rst <= 1'b0;
            repeat(2) @ (posedge clk);
        end
    endtask

    initial begin
        rst_dut();
    end

////////////////////////////////////////////////////////////////////////////////////////////////////
// DUT
////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        for(genvar g = 0; g < CFG_CNT; g++) begin : gen_dut

            // Interfaces
            ds_if #(    .DTYPE(DTYPE), .FC(DUT_CFG[g].fc)
                ) if_wr ();
            ds_if #(    .DTYPE(DTYPE), .FC(DUT_CFG[g].fc)
                ) if_rd ();

            cm_if_lvl #(.CAPACITY(DUT_CFG[g].capacity)
                ) if_wr_lvl ();
            cm_if_lvl #(.CAPACITY(DUT_CFG[g].capacity)
                ) if_rd_lvl ();

            // DUT
            ds_fifo #(
                .DTYPE      (DTYPE),
                .CAPACITY   (DUT_CFG[g].capacity),
                .ARCH       (DUT_CFG[g].arch)
            ) fifo (
                .i_clk          (clk),
                .i_rst          (rst),
                .if_wr          (if_wr),
                .if_if_wr_lvl   (if_wr_lvl),
                .if_rd          (if_rd),
                .if_if_rd_lvl   (if_rd_lvl)
            );

            // Drive
            initial begin
                if_wr_lvl.lvl_thr <= '0;
                if_rd_lvl.lvl_thr <= '0;
                if_wr.vld <= 1'b0;
                if_wr.data <= '0;
                if_rd.rdy <= 1'b0;
                repeat(10) @ (posedge clk);

                for(int i = 0; i < 16; i++) begin
                    if_wr.vld <= 1'b1;
                    if_wr.data <= i + 1;
                    @ (posedge clk);
                end
                if_wr.vld <= 1'b0;
                if_wr.data <= '0;

                repeat(16) begin
                    if_rd.rdy <= 1'b1;
                    @ (posedge clk);
                end
                if_rd.rdy <= 1'b0;
            end

        end
    endgenerate

endmodule
