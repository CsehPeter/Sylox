// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_sys
// Description  : System package that implements basic macros and functions
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __SYS_PKG_FN
`define __SYS_PKG_FN

import sys_pkg_type::*;
import sys_pkg_math::*;

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

    // Saturated ceil log2
    //
    // Provides protection agains -1 width bitvector in signal declarations. E.g. "logic [sclog2(W) - 1 : 0] signal"
    function sys_pkg_type::u32 sclog2(sys_pkg_type::u32 num);
        if(num <= 1)
            return 1;
        else
            return $clog2(num);
    endfunction


    // Register balancer
    //
    // Returns true if a stage considered registered by the register balancer
    function bit is_rb_reg(sys_pkg_type::u32 ts, sys_pkg_type::u32 rs, sys_pkg_type::u32 si);
        sys_pkg_type::f64 inc;      // Increment value
        sys_pkg_type::f64 f_acc;
        sys_pkg_type::u32 i_acc;
        sys_pkg_type::u32 lo;
        sys_pkg_type::u32 hi;
        sys_pkg_type::u32 idx;


        // Zero-length pipeline or no registered stages
        if(ts == 0 || rs == 0)
            return 1'b0;

        // Last stage
        if(si == ts - 1)
            return 1'b1;

        rs--;
        ts--;
        if(ts == 0 || rs == 0)
            return 1'b0;


        inc = $itor(ts) / $itor(rs);
        f_acc = 0.0;
        i_acc = 0;

        while(i_acc < ts) begin
            f_acc += inc;

            lo = i_acc;
            hi = sys_pkg_math::round(f_acc) - 1;
            idx = lo + (hi - lo) / 2;

            if(idx == si)
                return 1'b1;

            i_acc = sys_pkg_math::round(f_acc);
        end

        return 1'b0;
    endfunction

endpackage

`endif