

set scp_str [get_scopes]
set scps [regexp -all -inline {\S+} $scp_str]
for { set i 0 }  { $i < [array size scps] }  { incr i } {
   puts $scps($i)
}


add_wave {{/sim_ds}}
add_wave {{/sim_ds/\gen_dut[0].fifo /if_wr/vld}}
add_wave {{/sim_ds/\gen_dut[0].fifo /if_wr/vld}} -into fifo
add_wave {{/sim_ds/\gen_dut[0].fifo /if_wr/vld}} -into fifo -color #F0F0F0
add_wave_group fifo




get_scopes
/sim_ds/\gen_dut[0].wr_ds  /sim_ds/\gen_dut[0].rd_ds  /sim_ds/\gen_dut[0].wr_lvl  /sim_ds/\gen_dut[0].rd_lvl  /sim_ds/\gen_dut[1].wr_ds  /sim_ds/\gen_dut[1].rd_ds  /sim_ds/\gen_dut[1].wr_lvl  /sim_ds/\gen_dut[1].rd_lvl  /sim_ds/\gen_dut[2].wr_ds  /sim_ds/\gen_dut[2].rd_ds  /sim_ds/\gen_dut[2].wr_lvl  /sim_ds/\gen_dut[2].rd_lvl  /sim_ds/\gen_dut[3].wr_ds  /sim_ds/\gen_dut[3].rd_ds  /sim_ds/\gen_dut[3].wr_lvl  /sim_ds/\gen_dut[3].rd_lvl  /sim_ds/\gen_dut[4].wr_ds  /sim_ds/\gen_dut[4].rd_ds  /sim_ds/\gen_dut[4].wr_lvl  /sim_ds/\gen_dut[4].rd_lvl  /sim_ds/\gen_dut[5].wr_ds  /sim_ds/\gen_dut[5].rd_ds  /sim_ds/\gen_dut[5].wr_lvl  /sim_ds/\gen_dut[5].rd_lvl  /sim_ds/\gen_dut[0].fifo  /sim_ds/Block106_7 /sim_ds/\gen_dut[1].fifo  /sim_ds/Block106_13 /sim_ds/\gen_dut[2].fifo  /sim_ds/Block106_19 /sim_ds/\gen_dut[3].fifo  /sim_ds/Block106_25 /sim_ds/\gen_dut[4].fifo  /sim_ds/Block106_31 /sim_ds/\gen_dut[5].fifo  /sim_ds/Block106_33 /sim_ds/rst_dut /sim_ds/Always47_0 /sim_ds/Initial61_1 /sim_ds/Initial98_6 /sim_ds/Initial98_12 /sim_ds/Initial98_18 /sim_ds/Initial98_24 /sim_ds/Initial98_30 /sim_ds/Initial98_32
