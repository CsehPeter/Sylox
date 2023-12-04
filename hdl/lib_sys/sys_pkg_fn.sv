// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_sys
// Description  : System package that implements basic macros and functions
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __SYS_PKG_FN
`define __SYS_PKG_FN

import sys_pkg_type::*;

package sys_pkg_fn;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Macros
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Wrap-around
    `define WRAP(signal, dir=1, min=0, max=1) ( dir == 1 ?  (signal == max ? min : signal + 1'b1) : (signal == min ? max : signal - 1'b1))
    // TODO: Special case of WRAP. WRAP_INC_CNTR


    // Saturation
    `define SAT(signal, dir=1, lim=1) ( dir == 1 ?  (signal < lim ? signal + 1'b1 : lim) : (signal > lim ? signal - 1'b1 : lim))

////////////////////////////////////////////////////////////////////////////////////////////////////
// Functions
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Saturated Ceil Log2
    // Provides protection agains -1 width bitvector in signal declarations. E.g. "logic [sclog2(W) - 1 : 0] signal"
    function sys_pkg_type::u32 sclog2(sys_pkg_type::u32 num);
        if(num <= 1)
            return 1;
        else
            return $clog2(num);
    endfunction

endpackage

`endif