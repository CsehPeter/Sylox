// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_cm
// Description  :
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __CM_SORT
`define __CM_SORT

import sys_pkg_type::*;

module cm_sort #(
    parameter u32   DCNT    = 4,
    parameter u32   DWIDTH  = 8,
    parameter u32   REG_CNT = 1
)(
    input logic                                         i_clk,
    input logic                                         i_rst,

    input logic                                         i_vld,
    input logic [DCNT - 1 : 0][DWIDTH - 1 : 0]          i_data,

    output logic                                        o_vld,
    output logic [DCNT - 1 : 0][DWIDTH - 1 : 0]         o_data
);

////////////////////////////////////////////////////////////////////////////////////////////////////
// Functions & Constants
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Sum of arithmetic sequence starting from 1 to 'num' with difference of 1
    function u32 sum_arith_seq(u32 num);
        if(num % 2 == 0)
            return (num / 2) * (1 + num);
        else
            return (num / 2 + 1) * (num);
    endfunction

    // DCNT     : 2 , 4 , 8 , 16
    // STAGE    : 1 , 3 , 6 , 10
    localparam u32 DEGREE       = $clog2(DCNT);
    localparam u32 STAGE_CNT    = sum_arith_seq(DEGREE);


    typedef struct {
        bit is_reg;
        bit is_comp;
        u32 idx_other;
    } t_node;

    typedef t_node t_net_full [STAGE_CNT - 1 : 0][2**DEGREE - 1 : 0];

    function t_net_full gen_net();
        t_net_full net;

        u32 grp_offset;
        u32 cmp_offset;
        u32 offset;
        u32 cnt;
        u32 size;

        u32 idx_low;
        u32 idx_high;

        for(u32 d = 0; d < DEGREE; d++) begin                               // Degree
            for(u32 s = 0; s < d + 1; s++) begin                            // Stage
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

                            // Assign comparators
                            net[sum_arith_seq(d) + s][idx_low].is_comp = 1'b1;
                            net[sum_arith_seq(d) + s][idx_low].idx_other = idx_high;

                            net[sum_arith_seq(d) + s][idx_high].is_comp = 1'b1;
                            net[sum_arith_seq(d) + s][idx_high].idx_other = idx_low;
                        end
                    end

                end
            end
        end

        return net;
    endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Parameters of the network
    localparam t_net_full NET = gen_net();


    // Declaration of network logic
    logic [STAGE_CNT : 0][2**DEGREE - 1 : 0][DWIDTH - 1 : 0] c_net;



    // Connect input to stage 0
    generate
        for(genvar n = 0; n < DCNT; n++) begin
            assign c_net[0][n] = i_data[n];
        end
    endgenerate

    // Generate comparators
    generate
        for(genvar s = 0; s < STAGE_CNT; s++) begin
            for(genvar n = 0; n < 2**DEGREE; n++) begin

                localparam u32 il = n;                     // Low index
                localparam u32 ih = NET[s][n].idx_other;   // High index

                // Check for comparator
                if(NET[s][il].is_comp == 1'b1) begin
                    if(ih > n) begin


                        // Comparator
                        always_comb begin : p_cmp
                            if(c_net[s][il] > c_net[s][ih]) begin
                                c_net[s + 1][il] = c_net[s][ih];
                                c_net[s + 1][ih] = c_net[s][il];
                            end else begin
                                c_net[s + 1][il] = c_net[s][il];
                                c_net[s + 1][ih] = c_net[s][ih];
                            end
                        end
                    end
                end else begin
                    assign c_net[s + 1][il] = c_net[s][il];
                end
            end
        end
    endgenerate

    // Connect output to the last stage
    generate
        for(genvar n = 0; n < DCNT; n++) begin
            assign o_data[n] = c_net[STAGE_CNT][n];
        end
    endgenerate

endmodule

`endif