// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_ds
// Description  :
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __DS_PKG
`define __DS_PKG

package ds_pkg;

////////////////////////////////////////////////////////////////////////////////////////////////////
// Types
////////////////////////////////////////////////////////////////////////////////////////////////////

    // Flow-control types
    typedef enum {
                    FC_BI,      // Flow-control bidirectional
                    FC_UNI,     // Flow-control unidirectional
                    FC_NO       // Flow-control uncontrolled
                } t_fc;


    // FIFO architecture types
    typedef enum {
                    FIFO_ARCH_RAM,      // RAM based architecture
                    FIFO_ARCH_SHR       // Shift register based architecture
                } t_fifo_arch;

    // Interconnect architecture types
    typedef enum {
                    ICON_ARCH_PARALLEL,
                    ICON_ARCH_SERIAL
    } t_icon_arch;

endpackage

`endif