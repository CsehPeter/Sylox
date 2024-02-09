// The use of this code requires a license fise. If you lack the license fise, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_cm
// Description  : Provides a pipelined, parallel sorting logic. Uses Batcher odd-even sorting
//                  - Steps of generating the network:
//                      1. Generate sorting network that is the power of 2
//                      2. Exclude nodes that are outside of the data count requirement
//                      3. Merge stages if possible
//                      4. Determine registered stages
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __CM_SORT
`define __CM_SORT

import sys_pkg_type::*;
import sys_pkg_math::*;

module cm_sort #(
    parameter u32   DCNT        = 4,
    parameter u32   DWIDTH      = 8,
    parameter u32   REG_CNT     = 2
)(
    input logic                                 i_clk,
    input logic                                 i_rst,

    input logic                                 i_vld,
    input logic [DCNT - 1 : 0][DWIDTH - 1 : 0]  i_data,

    output logic                                o_vld,
    output logic [DCNT - 1 : 0][DWIDTH - 1 : 0] o_data
);

////////////////////////////////////////////////////////////////////////////////////////////////////
// Global Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////

    localparam u32 DEGREE = $clog2(DCNT);

    // Node: parameters to describe a point in the sorting network
    typedef struct {
        bit is_comp;
        u32 idx_other;
    } t_node;

    // Stage: parameters to describe a collection of nodes
    typedef struct {
        bit is_reg;
        t_node nodes [DCNT - 1 : 0];
    } t_stage;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameters Of Full Sorting Network
////////////////////////////////////////////////////////////////////////////////////////////////////

    localparam u32 STAGE_CNT_FULL = sum_arith_seq(DEGREE);
    typedef t_stage t_net_full [STAGE_CNT_FULL - 1 : 0];

    // Generate the model of Batcher sorting network
    function automatic t_net_full gen_full_net();
        t_net_full net;

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
                    offset = 2 ** (d + 1) * g;      // Starting index of the group
                    if(s > 0)
                        offset += 2 ** (d - s);     // Starting index of the comparator in the group

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


                            if(idx_low < DCNT && idx_high < DCNT) begin     // Exclude comparators out of DCNT (when DCNT is not power of 2)

                                // Search if the comparator can be moved back to an earlier stage
                                idx_stage = sum_arith_seq(d) + s;
                                if(idx_stage > 0) begin
                                    for(u32 is = idx_stage - 1; is > 0; is--) begin
                                        if(net[is].nodes[idx_low].is_comp != 1'b0 || net[is].nodes[idx_high].is_comp != 1'b0)
                                            break;
                                        idx_stage = is;
                                    end
                                end

                                // Assign comparators
                                net[idx_stage].nodes[idx_low].is_comp = 1'b1;
                                net[idx_stage].nodes[idx_low].idx_other = idx_high;

                                net[idx_stage].nodes[idx_high].is_comp = 1'b1;
                                net[idx_stage].nodes[idx_high].idx_other = idx_low;
                            end
                        end
                    end

                end
            end
        end

        return net;
    endfunction


    localparam t_net_full PNET_FULL = gen_full_net();

////////////////////////////////////////////////////////////////////////////////////////////////////
// Stage Count Of Reduced Sorting Network
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Get the number of stages of a reduced network (comparators are moved back and empty stages eliminated)
    function automatic u32 get_reduced_net_stage_cnt(t_net_full net_full);
        u32 red_stage_cnt = 0;
        u8 is_empty = 1;

        for(u32 s = 0; s < STAGE_CNT_FULL; s++) begin

            // Search for the presence of a comparator node
            is_empty = 1;
            for(u32 n = 0; n < DCNT; n++) begin
                if(net_full[s].nodes[n].is_comp == 1'b1) begin
                    red_stage_cnt += 1;
                    is_empty = 0;
                    break;
                end

                if(is_empty == 0)   // Move on if any comparator is found
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
// Registered Stages Of Reduced Sorting Network
////////////////////////////////////////////////////////////////////////////////////////////////////

    typedef t_stage t_net [STAGE_CNT - 1 : 0];

    function automatic t_net gen_rs_net(t_net_full net_full);
        t_net net;
        u8 is_reg;

        for(u32 s = 0; s < STAGE_CNT; s++) begin
            net[s].is_reg = sys_pkg_fn::is_rb_reg(STAGE_CNT, REG_CNT, s);

            for(u32 n = 0; n < DCNT; n++) begin
                net[s].nodes[n] = net_full[s].nodes[n];
            end
        end

        return net;
    endfunction


    localparam t_net PNET = gen_rs_net(PNET_FULL);

////////////////////////////////////////////////////////////////////////////////////////////////////
// Logic
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Declaration of network logic
    logic [STAGE_CNT : 0][DCNT - 1 : 0][DWIDTH - 1 : 0] c_net;


    // Connect input to stage 0

    assign c_net[0] = i_data;
    /*
    generate
        always_comb begin : p_input
            for(u32 n = 0; n < DCNT; n++) begin
                if(i_vld == 1'b1) begin
                    c_net[0][n] = i_data[n];
                end else begin
                    c_net[0][n] = '0;
                end
            end
        end
    endgenerate
    */


    // Generate comparators
    generate
        for(genvar s = 0; s < STAGE_CNT; s++) begin

            logic [DCNT - 1 : 0][DWIDTH - 1 : 0] c_stage;

            for(genvar n = 0; n < DCNT; n++) begin

                localparam u32 ia = n;                          // Self index
                localparam u32 ib = PNET[s].nodes[n].idx_other; // Other index

                // Comparator or wire
                if(PNET[s].nodes[ia].is_comp) begin
                    if(ib > ia) begin
                        always_comb begin : p_cmp
                            if(c_net[s][ia] > c_net[s][ib]) begin
                                c_stage[ia] = c_net[s][ib];
                                c_stage[ib] = c_net[s][ia];
                            end else begin
                                c_stage[ia] = c_net[s][ia];
                                c_stage[ib] = c_net[s][ib];
                            end
                        end
                    end
                end else begin
                    assign c_stage[ia] = c_net[s][ia];
                end

                // Register or combinational stage
                if(PNET[s].is_reg) begin : p_reg
                    always_ff @ (posedge i_clk)
                        c_net[s + 1][ia] <= c_stage[ia];
                end else begin : p_comb
                    assign c_net[s + 1][ia] = c_stage[ia];
                end

            end
        end
    endgenerate


    // Connect output to the last stage
    assign o_data = c_net[STAGE_CNT];

    /*
    generate
        for(genvar n = 0; n < DCNT; n++) begin
            assign o_data[n] = c_net[STAGE_CNT][n];
        end
    endgenerate
    */


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