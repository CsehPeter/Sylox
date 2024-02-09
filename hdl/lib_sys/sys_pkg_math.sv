// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_sys
// Description  : System package that implements math functions
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __SYS_PKG_MATH
`define __SYS_PKG_MATH

import sys_pkg_type::*;

package sys_pkg_math;

    // Sum of arithmetic sequence
    // starting from 1 to 'num' with difference of 1
    // E.g. 1 + 2 + 3 + 4 for num = 4
    function sys_pkg_type::u32 sum_arith_seq(sys_pkg_type::u32 num);
        if(num % 2 == 0)
            return (num / 2) * (1 + num);
        else
            return (num / 2 + 1) * (num);
    endfunction


    // Round real to integer
    function sys_pkg_type::u32 round(sys_pkg_type::f64 f);
        sys_pkg_type::u32 d2;
        sys_pkg_type::u32 val;

        d2 = $rtoi(10 * f) % 10;
        val = $rtoi(f);
        if(d2 >= 5)
            val++;

        return val;
    endfunction

endpackage

`endif