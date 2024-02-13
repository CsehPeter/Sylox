// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      :
// Description  :
////////////////////////////////////////////////////////////////////////////////////////////////////

import sys_pkg_type::*;
import cm_pkg::*;

module sim_cm_shr ();

////////////////////////////////////////////////////////////////////////////////////////////////////
// Clock & Reset
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Clock
    logic clk = 1'b0;
    always #5 clk = ~clk;

    // Reset
    logic rst = 1'b0;
    logic q_rst = 1'b0;

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

        repeat(5) @ (posedge clk);
        rst = 1'b1;
        @ (posedge clk);
        rst = 1'b0;
    end

    always_ff @ (posedge clk)
        q_rst <= rst;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Environment
////////////////////////////////////////////////////////////////////////////////////////////////////

    localparam u32 DUT_CNT = 8;
    localparam u32 DWIDTH = 8;

    typedef struct packed {
        u32 LEN;
        t_shr_rst RST_MODE;
    } t_param;


    localparam t_param PARAMS [0 : DUT_CNT - 1] = '{
        '{0, SHR_RST_FIRST},
        '{1, SHR_RST_FIRST},
        '{2, SHR_RST_FIRST},
        '{3, SHR_RST_FIRST},

        '{0, SHR_RST_ALL},
        '{1, SHR_RST_ALL},
        '{2, SHR_RST_ALL},
        '{3, SHR_RST_ALL}
    };

////////////////////////////////////////////////////////////////////////////////////////////////////
// Stimulus & Check
////////////////////////////////////////////////////////////////////////////////////////////////////

    function automatic logic [DWIDTH - 1 : 0] get_stim();
        i32 num;

        num = $random() % 2 ** (DWIDTH + 1);
        if(num < 0)
            num = -num;

        return num[DWIDTH - 1 : 0];
    endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////
// DUTs
////////////////////////////////////////////////////////////////////////////////////////////////////

    generate
        for(genvar i = 0; i < DUT_CNT; i++) begin
            logic [DWIDTH - 1 : 0] i_data;
            logic [DWIDTH - 1 : 0] data;
            logic [DWIDTH - 1 : 0] o_data;

            // DUT
            cm_shr #(
                .LEN(PARAMS[i].LEN),
                .DTYPE(logic [DWIDTH - 1 : 0]),
                .RST_MODE(PARAMS[i].RST_MODE)
            ) inst_shr (
                .i_clk(clk),
                .i_rst(q_rst),

                .i_data(i_data),
                .o_data(o_data)
            );

            // Stimulus
            initial begin
                for(u32 i = 1; i < 16; i++) begin
                    data = i[DWIDTH - 1 : 0];
                    @ (posedge clk);
                end
            end

            always_ff @ (posedge clk)
                i_data <= data;
        end
    endgenerate

endmodule