// The use of this code requires a license fise. If you lack the license fise, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_cm
// Description  : Provides a pipelined, parallel sorting logic. Uses Batcher odd-even sorting.
//                Lowest data goes to the lowest index
//                - Steps of generating the network:
//                      1. Generate sorting network that is the power of 2
//                      2. Exclude nodes that are outside of the data count requirement
//                      3. Merge stages if possible
//                      4. Determine the stage count of the reduced network
//                      5. Assign registers for the appropriate stages
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __CM_SORT
`define __CM_SORT

import sys_pkg_type::*;
import sys_pkg_math::*;
import cm_pkg::*;

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

// TODO: Handle the case if REG_CNT is greater than stage count.

////////////////////////////////////////////////////////////////////////////////////////////////////
// Types & Parameters
////////////////////////////////////////////////////////////////////////////////////////////////////

    localparam u32 DEGREE = $clog2(DCNT);
    localparam u32 STAGE_CNT_FULL = sum_arith_seq(DEGREE);

    // Node: parameters to describe a point in the sorting network
    typedef struct {
        bit is_comp;
        u32 idx_other;
    } t_pnode;

    // Stage: parameters to describe an array of nodes that belongs to the same stage of the network
    typedef struct {
        bit is_reg;
        t_pnode nodes [DCNT - 1 : 0];
    } t_pstage;

    // Net: parameters to describe an array of stages
    typedef struct {
        u32 stage_cnt;
        t_pstage stages [STAGE_CNT_FULL - 1 : 0];
    } t_pnet;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Parameters Of Full Sorting Network
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Generate the model of Batcher sorting network
    function automatic t_pnet gen_net();
        t_pnet net;

        u32 offset;
        u32 cnt;
        u32 size;

        u32 idx_low;
        u32 idx_high;
        u32 idx_stage;

        bit is_empty;

        //---- Sorting Network ----
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
                                        if(net.stages[is].nodes[idx_low].is_comp != 1'b0 || net.stages[is].nodes[idx_high].is_comp != 1'b0)
                                            break;
                                        idx_stage = is;
                                    end
                                end

                                // Assign comparators
                                net.stages[idx_stage].nodes[idx_low].is_comp = 1'b1;
                                net.stages[idx_stage].nodes[idx_low].idx_other = idx_high;

                                net.stages[idx_stage].nodes[idx_high].is_comp = 1'b1;
                                net.stages[idx_stage].nodes[idx_high].idx_other = idx_low;
                            end
                        end
                    end

                end
            end
        end


        //---- Stage Count ----
        net.stage_cnt = 0;
        for(u32 s = 0; s < STAGE_CNT_FULL; s++) begin

            // Search for the presence of a comparator node
            is_empty = 1'b1;
            for(u32 n = 0; n < DCNT; n++) begin
                if(net.stages[s].nodes[n].is_comp == 1'b1) begin
                    net.stage_cnt += 1;
                    is_empty = 0;
                    break;
                end

                if(is_empty == 0)   // Move on if any comparator is found
                    break;
            end

            if(is_empty == 1)       // If no comparator is found, then it's the end of not empty stages
                break;
        end


        //---- Registered Stages ----
        for(u32 s = 0; s < net.stage_cnt; s++) begin
            net.stages[s].is_reg = sys_pkg_fn::is_rb_reg(net.stage_cnt, REG_CNT, s);
        end


        return net;
    endfunction


    localparam t_pnet PNET = gen_net();

////////////////////////////////////////////////////////////////////////////////////////////////////
// Logic
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Declaration of network logic
    logic [PNET.stage_cnt : 0][DCNT - 1 : 0][DWIDTH - 1 : 0] c_net;


    // Connect input to stage 0
    assign c_net[0] = i_data;


    // Generate comparators
    generate
        for(genvar s = 0; s < PNET.stage_cnt; s++) begin : g_stage

            logic [DCNT - 1 : 0][DWIDTH - 1 : 0] c_stage;

            for(genvar n = 0; n < DCNT; n++) begin : g_node

                localparam u32 ia = n;                                  // Self index
                localparam u32 ib = PNET.stages[s].nodes[n].idx_other;  // Other index

                // Comparator or wire
                if(PNET.stages[s].nodes[ia].is_comp) begin
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
                if(PNET.stages[s].is_reg) begin : p_reg
                    always_ff @ (posedge i_clk)
                        c_net[s + 1][ia] <= c_stage[ia];
                end else begin : p_comb
                    assign c_net[s + 1][ia] = c_stage[ia];
                end

            end
        end
    endgenerate


    // Connect output to the last stage
    assign o_data = c_net[PNET.stage_cnt];


    // Valid shift register
    cm_shr #(
        .LEN(REG_CNT),
        .DTYPE(logic),
        .RST_MODE(SHR_RST_ALL)
    ) inst_vld_shr (
        .i_clk(i_clk),
        .i_rst(i_rst),

        .i_data(i_vld),
        .o_data(o_vld)
    );

endmodule

`endif