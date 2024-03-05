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
    localparam u8 INST_CNT      = 2;
    localparam u8 DCNT_LIM      = 16;
    localparam u32 DWIDTH_LIM   = 16;


    typedef logic [DCNT_LIM - 1 : 0][DWIDTH_LIM - 1 : 0] t_arr;

    // Generate stimulus
    function automatic t_arr gen_stim();
        t_arr stim;
        i32 num;

        for(u32 i = 0; i < DCNT_LIM; i++) begin
            num = $random() % 2 ** DWIDTH_LIM;
            if(num < 0)
                num = -num;
            stim[i] = num;
        end

        return stim;
    endfunction

    // Sort (Bubble)
    function automatic t_arr sort(t_arr unord);
        t_arr ord = unord;
        logic [DWIDTH_LIM - 1 : 0] tmp;

        for(u32 i = 0; i < DCNT_LIM - 1; i++) begin
            for(u32 j = 0; j < DCNT_LIM - 1 - i; j++) begin
                if(ord[j] > ord[j + 1]) begin
                    tmp = ord[j];
                    ord[j] = ord[j + 1];
                    ord[j + 1] = tmp;
                end
            end
        end

        return ord;
    endfunction

    // Check
    function automatic bit check_data_result(t_arr du, t_arr ds, u32 data_cnt, u32 data_width);
        t_arr du_full = du;
        t_arr ds_prg;

        for(u32 i = data_cnt; i < DCNT_LIM; i++) begin
            du_full[i] = '1;
        end
        ds_prg = sort(du_full);


        for(u32 i = 0; i < data_cnt; i++) begin
            if(ds[i] != ds_prg[i])
                return 1'b0;
        end

        return 1'b1;
    endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////
// DUTs
////////////////////////////////////////////////////////////////////////////////////////////////////

    logic result [INST_CNT - 1 : 0];

    generate
        for(genvar g = 0; g < INST_CNT; g++) begin : gen_duts

            // Parameters
            localparam u32 DCNT         = 4 + 2 * g;
            localparam u32 REG_CNT      = 0; //1 + g;
            localparam t_sort_dir DIR   = g % 2 == 0 ? SORT_MIN : SORT_MAX;

            localparam u32 IDX_WIDTH = sclog2(DCNT);

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
                .DIR(DIR)
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
                    @ (posedge clk);
                end

                req = '0;
                weight = '{default: '0};
                repeat(20) @ (posedge clk);

                repeat(20) begin
                    req = gen_stim();
                    for(u32 i = 0; i < DCNT; i++)
                        weight[i] = gen_stim();
                    @ (posedge clk);
                end

                req = '0;
                weight = '{default: '0};
                repeat(20) @ (posedge clk);
            end

        end
    endgenerate

endmodule