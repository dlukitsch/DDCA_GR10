# Copyright (C) 2017  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel MegaCore Function License Agreement, or other 
# applicable license agreement, including, without limitation, 
# that your use is for the sole purpose of programming logic 
# devices manufactured by Intel and sold by Intel or its 
# authorized distributors.  Please refer to the applicable 
# agreement for further details.

# Quartus Prime: Generate Tcl File for Project
# File: MIPS_mimi.tcl
# Generated on: Tue Jun  5 12:13:36 2018

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "MIPS"]} {
		puts "Project MIPS is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists MIPS]} {
		project_open -revision pipeline MIPS
	} else {
		project_new -revision pipeline MIPS
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone IV E"
	set_global_assignment -name DEVICE EP4CE115F29C7
	set_global_assignment -name TOP_LEVEL_ENTITY mimi
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 17.1.1
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "15:58:15  MAY 15, 2018"
	set_global_assignment -name LAST_QUARTUS_VERSION "17.0.0 Standard Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
	set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 1.2V
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim (VHDL)"
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
	set_global_assignment -name VHDL_SHOW_LMF_MAPPING_MESSAGES OFF
	set_global_assignment -name TIMEQUEST_MULTICORNER_ANALYSIS ON
	set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name VHDL_FILE ../serial_port.vhd
	set_global_assignment -name VHDL_FILE ../fwd.vhd
	set_global_assignment -name VHDL_FILE ../ctrl.vhd
	set_global_assignment -name VHDL_FILE ../pll_altera.vhd
	set_global_assignment -name VHDL_FILE ../wb_ram.vhd
	set_global_assignment -name VHDL_FILE ../ram_pkg.vhd
	set_global_assignment -name VHDL_FILE ../sync_pkg.vhd
	set_global_assignment -name VHDL_FILE ../sync.vhd
	set_global_assignment -name VHDL_FILE ../math_pkg.vhd
	set_global_assignment -name VHDL_FILE ../fifo_1c1r1w.vhd
	set_global_assignment -name VHDL_FILE ../dp_ram_1c1r1w.vhd
	set_global_assignment -name VHDL_FILE ../serial_port_tx_fsm_pkg.vhd
	set_global_assignment -name VHDL_FILE ../serial_port_tx_fsm.vhd
	set_global_assignment -name VHDL_FILE ../serial_port_rx_fsm_pkg.vhd
	set_global_assignment -name VHDL_FILE ../serial_port_rx_fsm.vhd
	set_global_assignment -name VHDL_FILE ../serial_port_pkg.vhd
	set_global_assignment -name VHDL_FILE ../serial_port_wrapper.vhd
	set_global_assignment -name VHDL_FILE ../ocram_altera.vhd
	set_global_assignment -name VHDL_FILE ../core.vhd
	set_global_assignment -name VHDL_FILE ../mimi.vhd
	set_global_assignment -name SDC_FILE ../pipeline.sdc
	set_global_assignment -name VHDL_FILE ../imem_altera.vhd
	set_global_assignment -name VHDL_FILE ../wb.vhd
	set_global_assignment -name VHDL_FILE ../regfile.vhd
	set_global_assignment -name VHDL_FILE ../pipeline.vhd
	set_global_assignment -name VHDL_FILE ../op_pack.vhd
	set_global_assignment -name VHDL_FILE ../memu.vhd
	set_global_assignment -name VHDL_FILE ../mem.vhd
	set_global_assignment -name VHDL_FILE ../jmpu.vhd
	set_global_assignment -name VHDL_FILE ../fetch.vhd
	set_global_assignment -name VHDL_FILE ../exec.vhd
	set_global_assignment -name VHDL_FILE ../decode.vhd
	set_global_assignment -name VHDL_FILE ../core_pack.vhd
	set_global_assignment -name VHDL_FILE ../alu.vhd
	set_location_assignment PIN_Y2 -to clk_pin
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk_pin
	set_location_assignment PIN_M23 -to reset_pin
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to reset_pin
	set_location_assignment PIN_G12 -to rx
	set_location_assignment PIN_G9 -to tx
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to rx
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to tx
	set_location_assignment PIN_M21 -to intr_pin[0]
	set_location_assignment PIN_N21 -to intr_pin[1]
	set_location_assignment PIN_R24 -to intr_pin[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to intr_pin[2]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to intr_pin[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to intr_pin[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to intr_pin
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
