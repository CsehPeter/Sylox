// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_cm
// Description  :
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __CM_IF_LVL
`define __CM_IF_LVL

import sys_pkg_type::*;
import sys_pkg_fn::*;

interface cm_if_lvl #(
    parameter u32 CAPACITY = 0
)();
    logic                                   lim;        // Limit, boundary of the represented range (E.g.: empty, full)
    logic [sclog2(CAPACITY + 1) - 1 : 0]    lvl;        // Level
    logic [sclog2(CAPACITY + 1) - 1 : 0]    lvl_thr;    // Level threshold
    logic                                   lvl_gte;    // Level is Greater-Than-or-Equal to threshold


    modport mst (
                    input lvl_thr,
                    output lim, lvl, lvl_gte
                );

    modport slv (
                    input lim, lvl, lvl_gte,
                    output lvl_thr
                );
endinterface

`endif