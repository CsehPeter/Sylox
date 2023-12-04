// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_cm
// Description  : Common package for common module types and constants
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __CM_PKG
`define __CM_PKG

import sys_pkg_type::*;

package cm_pkg;

    // Order
    typedef enum {
                    ORD_MIN,    // Minimum value of the elements
                    ORD_MAX,    // Maximum value of the elements
                    ORD_SORT    // Sorted array
    } t_ord_type;

    // Arbiter
    typedef enum {
                    ARB_MIN,
                    ARB_MAX
                    // TODO: add more
    } t_arb_algo;



    // Binary tree
    function sys_pkg_type::u32 bin_tree_stage_count(sys_pkg_type::u32 in_cnt);
        sys_pkg_type::u32 cur_cnt = in_cnt;
        sys_pkg_type::u32 stage_cnt = 1;
        while(cur_cnt != 1) begin
            cur_cnt = $clog2(cur_cnt)**2 / 2;
            stage_cnt = stage_cnt + 1;
        end
        return stage_cnt;
    endfunction


    //
    function bit is_stage_reg(sys_pkg_type::u32 total_stage_cnt, sys_pkg_type::u32 reg_stage_cnt, sys_pkg_type::u32 cur_stage);

    endfunction

endpackage

`endif