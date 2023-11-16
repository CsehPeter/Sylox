// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_cm
// Description  : Common package that implements basic functions and macros
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __CM_PKG_FN
`define __CM_PKG_FN

import cm_pkg_type::*;

package cm_pkg_fn;

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
    function u32 sclog2(u32 num);
        if(num < 1)
            return 0;
        else
            return $clog2(num);
    endfunction

endpackage

`endif