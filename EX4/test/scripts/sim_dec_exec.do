vlib work
vmap work work

vcom -work work ../src/core_pack.vhd
vcom -work work ../src/op_pack.vhd
vcom -work work ../src/alu.vhd
vcom -work work -2008 ../src/decode.vhd
vcom -work work -2008 ../src/exec.vhd
vcom -work work -2008 ../src/regfile.vhd
vcom -work work -2008 tb/tb_util_pkg.vhd
vcom -work work -2008 tb/dec_exec_tb.vhd

vsim work.dec_exec_tb

# signals for debugging
add wave -radix hex /dec_exec_tb/decode_inst/*
add wave -radix hex /dec_exec_tb/exec_inst/*

run 5 us

