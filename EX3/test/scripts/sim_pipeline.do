vcom -work work ../src/core_pack.vhd
vcom -work work ../src/op_pack.vhd
vcom -work work ../src/alu.vhd
vcom -work work ../src/decode.vhd
vcom -work work ../src/exec.vhd
vcom -work work -2008 ../src/fetch.vhd
vcom -work work -2008 ../src/jmpu.vhd
vcom -work work -2008 ../src/memu.vhd
vcom -work work -2008 ../src/mem.vhd
vcom -work work ../src/regfile.vhd
vcom -work work -2008 ../src/wb.vhd
vcom -work work ../src/imem_altera.vhd
vcom -work work -2008 tb/pipeline_tb.vhd

vsim work.pipeline_tb

add wave -format logic /pipeline_tb/UUT/clk
add wave -format logic /pipeline_tb/UUT/reset
add wave /pipeline_tb/UUT/mem_out
add wave -format literal -radix hex /pipeline_tb/UUT/pc_out_fetch
add wave -format literal -radix hex /pipeline_tb/UUT/instr_fetch

run 1 us
