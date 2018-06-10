vcom -work work ../src/core_pack.vhd
vcom -work work ../src/op_pack.vhd
vcom -work work ../src/alu.vhd
vcom -work work -2008 ../src/decode.vhd
vcom -work work -2008 ../src/exec.vhd
vcom -work work -2008 ../src/fetch.vhd
vcom -work work -2008 ../src/jmpu.vhd
vcom -work work -2008 ../src/memu.vhd
vcom -work work -2008 ../src/mem.vhd
vcom -work work -2008 ../src/regfile.vhd
vcom -work work -2008 ../src/wb.vhd
vcom -work work -2008 ../src/ctrl.vhd
vcom -work work -2008 ../src/fwd.vhd
vcom -work work ../src/ocram_altera.vhd
vcom -work work ../src/imem_altera.vhd
vcom -work work -2008 tb/pipeline_tb.vhd

vsim work.pipeline_tb

# signals for debugging
add wave -radix hex /pipeline_tb/UUT/*
add wave -radix hex /pipeline_tb/UUT/ctrl_inst/*

run 5 us

