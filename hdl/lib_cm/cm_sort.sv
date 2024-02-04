// The use of this code requires a license fise. If you lack the license fise, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_cm
// Description  : Provides a pipelined, parallel sorting logic. Uses Batcher odd-even sorting
//                  - Steps of generating the network:
//                      1. Generate sorting network that is the power of 2
//                      2. Exclude nodes that are outside of the data count requirement
//                      3. Merge stages if possible
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __CM_SORT
`define __CM_SORT

import sys_pkg_type::*;
import sys_pkg_math::*;

module cm_sort #(
    parameter u32   DATA_CNT    = 4,
    parameter u32   DATA_WIDTH  = 8,
    parameter u32   REG_CNT     = 2
)(
    input logic                                         i_clk,
    input logic                                         i_rst,

    input logic                                         i_vld,
    input logic [DATA_CNT - 1 : 0][DATA_WIDTH - 1 : 0]  i_data,

    output logic                                        o_vld,
    output logic [DATA_CNT - 1 : 0][DATA_WIDTH - 1 : 0] o_data
);

////////////////////////////////////////////////////////////////////////////////////////////////////
// Global Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////

    localparam u32 DEGREE = $clog2(DATA_CNT);

    // Node: represents the neccessary parameters to describe a node in the sorting network
    typedef struct {
        bit is_reg;
        bit is_comp;
        u32 idx_other;
    } t_node;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameters Of Full Sorting Network
////////////////////////////////////////////////////////////////////////////////////////////////////

    localparam u32 STAGE_CNT_FULL   = sum_arith_seq(DEGREE);
    typedef t_node t_net_full [STAGE_CNT_FULL - 1 : 0][DATA_CNT - 1 : 0];

    // Generate the model of Batcher sorting network
    function automatic t_net_full gen_full_net();
        t_net_full net;

        u32 grp_offset;
        u32 cmp_offset;
        u32 offset;
        u32 cnt;
        u32 size;

        u32 idx_low;
        u32 idx_high;
        u32 idx_stage;

        for(u32 d = 0; d < DEGREE; d++) begin                               // Degree
            for(u32 s = 0; s < d + 1; s++) begin                            // Stage (relative stage in a degree)
                for(u32 g = 0; g < (2 ** (DEGREE - d - 1)); g++) begin      // Group

                    // Offset
                    grp_offset = 2 ** (d + 1) * g;      // Starting index of the group
                    cmp_offset = 2 ** (d - s);          // Starting index of the comparator in the stage
                    if(s == 0)
                        offset = grp_offset;
                    else
                        offset = grp_offset + cmp_offset;

                    // Count
                    if(s == 0)
                        cnt = 1;
                    else
                        cnt = 2 ** s - 1;

                    // Size
                    size = 2 ** (d - s);


                    // Generate comparators
                    for(u32 i = 0; i < cnt; i++) begin
                        for(u32 j = 0; j < size; j++) begin

                            // Calculate comparator indexes
                            idx_low = offset + i * 2 * size + j;
                            idx_high = idx_low + size;


                            if(idx_low < DATA_CNT && idx_high < DATA_CNT) begin     // Exclude comparators when DATA_CNT is not power of 2

                                // Search if the comparator can be brought forward (merged to previous stage)
                                idx_stage = sum_arith_seq(d) + s;
                                if(idx_stage > 0)
                                    for(u32 is = idx_stage - 1; is > 0; is--) begin
                                        if(net[is][idx_low].is_comp != 1'b0 || net[is][idx_high].is_comp != 1'b0)
                                            break;
                                        idx_stage = is;
                                    end

                                // Assign comparators
                                net[idx_stage][idx_low].is_comp = 1'b1;
                                net[idx_stage][idx_low].idx_other = idx_high;

                                net[idx_stage][idx_high].is_comp = 1'b1;
                                net[idx_stage][idx_high].idx_other = idx_low;
                            end
                        end
                    end

                end
            end
        end

        net = gen_reg_stages(net);
        return net;
    endfunction


    localparam t_net_full PNET_FULL = gen_full_net();


    // TODO: Dummy function, replace it with real
    function automatic t_net_full gen_reg_stages(t_net_full net);
        for(u32 i = 0; i < STAGE_CNT_FULL; i++) begin
            for(u32 j = 0; j < DATA_CNT; j++) begin
                if(i < REG_CNT) begin
                    net[i][j].is_reg = 1'b1;
                end
            end
        end

        return net;
    endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////
// Stage Count Of Reduced Sorting Network
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Get the number of stages of a reduced network
    function automatic u32 get_reduced_net_stage_cnt(t_net_full net_full);
        u32 red_stage_cnt = 0;
        u8 is_empty = 1;

        for(u32 i = 0; i < STAGE_CNT_FULL; i++) begin

            // Search for the presence of a comparator node
            is_empty = 1;
            for(u32 j = 0; j < DATA_CNT; j++) begin
                if(net_full[i][j].is_comp == 1'b1) begin
                    red_stage_cnt += 1;
                    is_empty = 0;
                    break;
                end

                if(is_empty == 0)
                    break;
            end

            // If comparator is not found, then it's the end of not empty stages
            if(is_empty == 1)
                break;
        end

        return red_stage_cnt;
    endfunction


    localparam u32 STAGE_CNT = get_reduced_net_stage_cnt(PNET_FULL);

////////////////////////////////////////////////////////////////////////////////////////////////////
// Logic
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Declaration of network logic
    logic [STAGE_CNT : 0][DATA_CNT - 1 : 0][DATA_WIDTH - 1 : 0] c_net;


    // Connect input to stage 0
    generate
        always_comb begin : p_input
            for(u32 n = 0; n < DATA_CNT; n++) begin
                if(i_vld == 1'b1) begin
                    c_net[0][n] = i_data[n];
                end else begin
                    c_net[0][n] = '0;
                end
            end
        end
    endgenerate

    // Generate comparators
    generate
        for(genvar s = 0; s < STAGE_CNT; s++) begin
            for(genvar n = 0; n < DATA_CNT; n++) begin

                localparam u32 ia = n;                          // Self index
                localparam u32 ib = PNET_FULL[s][n].idx_other;  // Other index

                // Check for comparator
                case({PNET_FULL[s][ia].is_comp, PNET_FULL[s][ia].is_reg})

                    // Wire
                    2'b00: begin
                        assign c_net[s + 1][ia] = c_net[s][ia];
                    end

                    // Register
                    2'b01: begin
                        always_ff @ (posedge i_clk)
                            c_net[s + 1][ia] <= c_net[s][ia];
                    end

                    // Comparator
                    2'b10: begin
                        if(ib > ia) begin
                            always_comb begin : p_comb_cmp
                                if(c_net[s][ia] > c_net[s][ib]) begin
                                    c_net[s + 1][ia] = c_net[s][ib];
                                    c_net[s + 1][ib] = c_net[s][ia];
                                end else begin
                                    c_net[s + 1][ia] = c_net[s][ia];
                                    c_net[s + 1][ib] = c_net[s][ib];
                                end
                            end
                        end
                    end

                    // Comparator + register
                    2'b11: begin
                        if(ib > ia) begin
                            always_ff @ (posedge i_clk) begin : p_seq_cmp
                                if(c_net[s][ia] > c_net[s][ib]) begin
                                    c_net[s + 1][ia] <= c_net[s][ib];
                                    c_net[s + 1][ib] <= c_net[s][ia];
                                end else begin
                                    c_net[s + 1][ia] <= c_net[s][ia];
                                    c_net[s + 1][ib] <= c_net[s][ib];
                                end
                            end
                        end
                    end
                endcase
            end
        end
    endgenerate

    // Connect output to the last stage
    generate
        for(genvar n = 0; n < DATA_CNT; n++) begin
            assign o_data[n] = c_net[STAGE_CNT][n];
        end
    endgenerate


    // Valid shift register
    generate
        if(REG_CNT == 0) begin : gen_no_vld_reg

            assign o_vld = i_vld;

        end else begin : gen_vld_shr

            logic [REG_CNT - 1 : 0] q_vld_shr;

            always_ff @ (posedge i_clk) begin : p_vld_shr
                if(i_rst == 1'b1) begin
                    q_vld_shr <= '0;
                end else begin
                    for(u32 i = 0; i < REG_CNT; i++)
                        if(i == 0)
                            q_vld_shr[i] <= i_vld;
                        else
                            q_vld_shr[i] <= q_vld_shr[i - 1];
                end
            end

            assign o_vld = q_vld_shr[REG_CNT - 1];

        end
    endgenerate

endmodule

`endif