// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      :
// Description  :
////////////////////////////////////////////////////////////////////////////////////////////////////

import sys_pkg_type::*;
import sys_pkg_fn::*;
import cm_pkg::*;

module sim_cm_arbiter ();

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
// Test Environment
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Parameters of the test
    localparam u32 INST_CNT = 2;
    localparam u32 DWIDTH = 8;

    // Generate stimulus
    function automatic logic [DWIDTH - 1 : 0] gen_stim();
        u32 num;
        logic [DWIDTH - 1 : 0] retval;

        num = $random() % 2 ** DWIDTH;
        if(num < 0)
            num = -num;

        retval = num[DWIDTH - 1 : 0];

        return retval;
    endfunction


    // Check
    /*
    function automatic bit check_result();

    endfunction
    */

////////////////////////////////////////////////////////////////////////////////////////////////////
// DUTs
////////////////////////////////////////////////////////////////////////////////////////////////////

    logic result [INST_CNT - 1 : 0];

    generate
        for(genvar g = 0; g < INST_CNT; g++) begin : gen_duts

            // Parameters
            localparam u32 DCNT         = 4 + 2 * g;
            localparam u32 REG_CNT      = 0; //1 + g;
            localparam t_arb_algo ALGO  = g % 2 == 0 ? ARB_MIN : ARB_MAX;

            localparam u32      IDX_WIDTH = sclog2(DCNT);

            // Signals
            logic [DCNT - 1 : 0]                  req;
            logic [DCNT - 1 : 0][DWIDTH - 1 : 0]  weight;

            logic [DCNT - 1 : 0]                  i_req;
            logic [DCNT - 1 : 0][DWIDTH - 1 : 0]  i_weight;
            logic                                 o_vld;
            logic [IDX_WIDTH - 1 : 0]             o_gnt;

            // DUT
            cm_arbiter #(
                .DCNT(DCNT),
                .DWIDTH(DWIDTH),
                .REG_CNT(REG_CNT),
                .ALGO(ALGO)
            ) inst_cm_arbiter (
                .i_clk(clk),
                .i_rst(rst),

                .i_req(i_req),
                .i_weight(i_weight),
                .o_vld(o_vld),
                .o_gnt(o_gnt)
            );

            // FF input
            always_ff @ (posedge clk) begin
                i_req <= req;
                i_weight <= weight;
            end

            // Stimulus
            initial begin
                // Init
                req = 1'b0;
                result[g] = 1'b0;
                weight = '{default: '0};

                repeat(20) @ (posedge clk);

                // Stimulus
                repeat(20) begin
                    req = '1;
                    for(u32 i = 0; i < DCNT; i++)
                        weight[i] = gen_stim();
                    /*
                    @ (posedge clk);
                    req = '0;
                    weight = '{default: '0};
                    */
                    @ (posedge clk);
                end
            end

        end
    endgenerate


endmodule