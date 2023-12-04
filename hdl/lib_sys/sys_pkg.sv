// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_sys
// Description  :
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __SYS_PKG
`define __SYS_PKG

package sys_pkg;

    /* TODO:
        - A macro might be a good idea to switch easily between synchronous and asynchronous reset. This macro could be included in every always_ff block
        - Constant for global reset polarity
    */



    // Reset for sensitivity list in always_ff
    `define RST_SENS(rst) (or negedge rst)      // Async negedge
    // `define RST_SENS(rst) (or posedge rst)      // Async posedge
    // `define RST_SENS(rst) ()                    // Sync






    // Reset
    typedef enum {RST_SYNC, RST_ASYNC} t_rst_sync;      // Reset synchronicity

    typedef struct {
        t_rst_sync  sync;
        logic       active;
    } t_rst;

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