vlib work
vmap work work 

#compilation order is important!
vcom -work work ../src/core_pack.vhd
vcom -work work ../src/imem_altera.vhd

vcom -work work -2008 ../src/fetch.vhd

