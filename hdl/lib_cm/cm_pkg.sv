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



    /*
    function bit is_stage_reg(sys_pkg_type::u32 total_stage_cnt, sys_pkg_type::u32 reg_stage_cnt, sys_pkg_type::u32 cur_stage);

    endfunction
    */

endpackage

`endif