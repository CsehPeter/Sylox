// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      :
// Description  :
////////////////////////////////////////////////////////////////////////////////////////////////////

import sys_pkg_type::*;
import cm_pkg::*;

module sim_cm_sort ();

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
    localparam u8 INST_CNT      = 4;
    localparam u8 DCNT_LIM      = 32;
    localparam u8 DWIDTH_LIM    = 16;
    localparam u8 REG_CNT_LIM   = 16;

    // Generate stimulus
    typedef logic [DCNT_LIM - 1 : 0][DWIDTH_LIM - 1 : 0] t_arr;
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
    function automatic bit check_result(t_arr du, t_arr ds, u32 data_cnt, u32 data_width);
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
            localparam DCNT     = 4 + 2 * g;
            localparam DWIDTH   = 16;
            localparam REG_CNT      = 1 + g;


            // Signals
            logic i_vld;
            logic [DCNT - 1 : 0][DWIDTH - 1 : 0] i_data;
            logic o_vld;
            logic [DCNT - 1 : 0][DWIDTH - 1 : 0] o_data;

            // DUT
            cm_sort #(
                .DCNT(DCNT),
                .DWIDTH(DWIDTH),
                .REG_CNT(REG_CNT)
            ) sort (
                .i_clk(clk),
                .i_rst(rst),
                .i_vld(i_vld),
                .i_data(i_data),
                .o_vld(o_vld),
                .o_data(o_data)
            );

            // Stimulus
            t_arr stim;
            logic vld;
            logic [DCNT - 1 : 0][DWIDTH - 1 : 0] data;

            initial begin
                vld = 1'b0;
                result[g] = 1'b0;
                stim = gen_stim();

                repeat(20) @ (posedge (clk));

                vld = 1'b1;
                for(u32 i = 0; i < DCNT; i++) begin
                    stim[i] = stim[i][DWIDTH - 1 : 0];
                    data[i] = stim[i];
                end

                @ (posedge clk);
                vld = 1'b0;
            end

            always_ff @ (posedge clk) begin
                i_vld <= vld;
                i_data <= data;
            end

            // Check result
            always_ff @ (posedge clk)
                if(o_vld)
                    result[g] <= check_result(stim, o_data, DCNT, DWIDTH);

        end
    endgenerate


endmodule