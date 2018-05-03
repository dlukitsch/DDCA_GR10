#first compile testbench ad utility package
vcom -work work ../../src/core_pack.vhd
vcom -work work ../../src/op_pack.vhd
vcom -work work ../tb/tb_util_pkg.vhd
vcom -work work ../tb/alu_tb_fileio.vhd

#start simulation
vsim -t ps work.alu_tb_fileio