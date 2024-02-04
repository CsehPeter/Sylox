// The use of this code requires a license file. If you lack the license file, you are prohibited to use it!

////////////////////////////////////////////////////////////////////////////////////////////////////
// Author       : Peter Cseh
// Library      : lib_sys
// Description  : System package that defines basic data types
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef __SYS_PKG_TYPE
`define __SYS_PKG_TYPE

package sys_pkg_type;

    typedef byte unsigned       u8;
    typedef shortint unsigned   u16;
    typedef int unsigned        u32;
    typedef longint unsigned    u64;

    typedef byte signed         i8;
    typedef shortint signed     i16;
    typedef int signed          i32;
    typedef longint signed      i64;

endpackage

`endif