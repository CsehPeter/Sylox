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

    // Shift register
    typedef enum {
        SHR_RST_FIRST,
        SHR_RST_FULL
    } t_shr_rst;

    // Arbiter
    typedef enum {
        ARB_MIN,
        ARB_MAX
        // TODO: add more
    } t_arb_algo;


endpackage

`endif