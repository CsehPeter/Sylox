// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : verif_sim
// Description  :
////////////////////////////////////////////////////////////////////////////////////////////////////

import sys_pkg_type::*;
import ds_pkg::*;

module sim_ds ();

    localparam type     DTYPE       = logic [7 : 0];
    localparam u32      CAPACITY    = 8;

    // Interfaces
    ds_if #(
        .DTYPE  (DTYPE),
        .FC     (FC_BI)
    ) ds [1 : 0] ();

    cm_if_lvl #(
        .CAPACITY(CAPACITY)
    ) lvl [1 : 0] ();

    // DUT
    ds_fifo #(
        .DTYPE      (DTYPE),
        .CAPACITY   (CAPACITY),
        .ARCH       (FIFO_ARCH_SHR)
    ) fifo (
        .i_clk      (i_clk),
        .i_rst      (i_rst),
        .if_wr      (ds[0]),
        .if_wr_lvl  (lvl[0]),
        .if_rd      (ds[1]),
        .if_rd_lvl  (lvl[1])
    );

    assign lvl[0].lvl_thr = '0;
    assign lvl[1].lvl_thr = '0;

endmodule
