vcom -work work ../src/core_pack.vhd
vcom -work work ../src/op_pack.vhd
vcom -work work ../src/util_pkg.vhd
vcom -work work tb/tb_util_pkg.vhd
vcom -work work -2008 tb/memu_tb.vhd
vsim -t ps work.memu_tb
