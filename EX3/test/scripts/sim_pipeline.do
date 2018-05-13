vcom -work work ../src/core_pack.vhd
vcom -work work ../src/op_pack.vhd
vcom -work work -2008 tb/pipeline_tb.vhd
vsim work.pipeline_tb

add wave -format logic /pipeline_tb/clk
add wave -format logic /pipeline_tb/reset
add wave -format logic /pipeline_tb/mem_out

