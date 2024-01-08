
create_project sylox C:/Users/Peter/peter/dev/sylox/_proj -part xc7vx485tffg1157-1

add_files {C:/Users/Peter/peter/dev/sylox/_proj/src/hdl/lib_sys/sys_pkg_fn.sv C:/Users/Peter/peter/dev/sylox/_proj/src/hdl/lib_cm/cm_arbiter.sv }
update_compile_order -fileset sources_1

launch_simulation
source sim_ds.tcl

close_sim

run 200ns


save_wave_config {C:/Users/Peter/peter/dev/sylox/_proj/sim_ds_behav.wcfg}
add_files -fileset sim_1 -norecurse C:/Users/Peter/peter/dev/sylox/_proj/sim_ds_behav.wcfg
set_property xsim.view C:/Users/Peter/peter/dev/sylox/_proj/sim_ds_behav.wcfg [get_filesets sim_1]

restart