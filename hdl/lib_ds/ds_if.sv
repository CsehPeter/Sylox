// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_ds
// Description  :
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __DS_IF
`define __DS_IF

import ds_pkg::*;

interface ds_if #(
    parameter type DTYPE    = logic [7 : 0],
    parameter t_fc FC       = FC_BI
)(
);
    logic vld;      // Transmitter ready to send
    logic rdy;      // Receiver ready to receive
    DTYPE data;

    logic xfer;     // A single transmission event

    generate
        case(FC)
            FC_BI:
                assign xfer = vld & rdy;
            FC_UNI:
                assign xfer = vld;
            FC_NO:
                assign xfer = 1'b1;
        endcase
    endgenerate


    modport mst (
        output data, vld,
        input rdy, xfer
    );

    modport slv (
        output rdy,
        input vld, data, xfer
    );

endinterface

`endif