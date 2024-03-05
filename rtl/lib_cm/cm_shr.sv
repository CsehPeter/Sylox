// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_cm
// Description  : Simple shift register for delaying data
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __CM_SHR
`define __CM_SHR

import sys_pkg_type::*;
import cm_pkg::*;

module cm_shr #(
    parameter u32       LEN         = 2,
    parameter type      DTYPE       = logic [7 : 0],
    parameter t_shr_rst RST_MODE    = SHR_RST_FIRST
)(
    input logic     i_clk,
    input logic     i_rst,

    input DTYPE     i_data,
    output DTYPE    o_data
);

    generate
        if(LEN == 0) begin : g_bypass
            assign o_data = i_data;
        end else begin : g_shr

            DTYPE q_shr [LEN - 1 : 0];

            always_ff @ (posedge i_clk) begin : p_shr
                for(u32 i = 0; i < LEN; i++)
                    if(i == 0)
                        if(i_rst == 1'b1)
                            q_shr[i] <= '0;
                        else
                            q_shr[i] <= i_data;
                    else
                        if(i_rst == 1'b1 && RST_MODE == SHR_RST_ALL)
                            q_shr[i] <= '0;
                        else
                            q_shr[i] <= q_shr[i - 1];
            end

            assign o_data = q_shr[LEN - 1];
        end
    endgenerate

endmodule

`endif