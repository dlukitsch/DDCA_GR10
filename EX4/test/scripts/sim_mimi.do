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
vcom -work work -2008 ../src/math_pkg.vhd
vcom -work work -2008 ../src/sync.vhd
vcom -work work -2008 ../src/sync_pkg.vhd
vcom -work work -2008 ../src/ram_pkg.vhd
vcom -work work -2008 ../src/wb_ram.vhd
vcom -work work -2008 ../src/dp_ram_1c1r1w.vhd
vcom -work work -2008 ../src/fifo_1c1r1w.vhd
vcom -work work -2008 ../src/serial_port_rx_fsm.vhd
#vcom -work work -2008 ../src/serial_port_rx_fsm_pkg.vhd
vcom -work work -2008 ../src/serial_port_tx_fsm.vhd
#vcom -work work -2008 ../src/serial_port_tx_fsm_pkg.vhd
vcom -work work -2008 ../src/serial_port.vhd
vcom -work work -2008 ../src/serial_port_pkg.vhd
vcom -work work -2008 ../src/serial_port_wrapper.vhd
vcom -work work -2008 ../src/pll_altera.vhd
vcom -work work -2008 ../src/core.vhd
vcom -work work -2008 ../src/mimi.vhd

vcom -work work -2008 tb/mimi_tb.vhd

vsim work.mimi_tb

# signals for debugging
add wave -radix hex /mimi_tb/UUT/*
add wave -radix ASCII /mimi_tb/test_uart/rx_data
add wave -radix hex /mimi_tb/UUT/core/pipeline/*

run 1 ms
