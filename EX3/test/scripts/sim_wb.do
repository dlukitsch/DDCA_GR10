vcom -work work ../src/core_pack.vhd
vcom -work work ../src/op_pack.vhd
vcom -work work tb/tb_util_pkg.vhd
vcom -work work -2008 tb/wb_tb.vhd
vsim -t ps work.wb_tb
