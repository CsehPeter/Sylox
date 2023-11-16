// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_cm
// Description  : Common package that implements basic functions
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __CM_PKG_SYS
`define __CM_PKG_SYS

package cm_pkg_sys;

    // Reset
    typedef enum {RST_SYNC, RST_ASYNC} t_rst_sync;      // Reset synchronicity

    typedef struct {
        t_rst_sync  sync;
        logic       active;
    } t_rst;


    // Clock
    typedef enum {CLK_POS, CLK_NEG} t_clk_pol;


    // System
    typedef struct {
        t_rst rst;
        t_clk clk;
    } t_sys;







    // Clock edge. Either "posedge" or "negedge"
    `ifndef __CLK_EDGE
        `define __CLK_EDGE posedge
    `endif

    // Reset synchronicity
    `ifndef __RST_SYNC
        `define __RST_SYNC
    `endif

endpackage

`endif