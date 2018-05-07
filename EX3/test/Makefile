
VSIM=~/intelFPGA/17.1/modelsim_ase/linuxaloem/vsim

compile_memu: 
	$(VSIM) -c -do "do scripts/compile_memu.do;quit -f"

sim_memu: compile_memu
	$(VSIM) -c -do "do scripts/sim_memu.do;run 1 us;quit -f" 

compile_jmpu: 
	$(VSIM) -c -do "do scripts/compile_jmpu.do;quit -f"

compile_fetch: 
	$(VSIM) -c -do "do scripts/compile_fetch.do;quit -f"

sim_fetch: compile_fetch
	$(VSIM) -c -do "do scripts/sim_fetch.do;run 1 us;quit -f" 

compile_mem: 
	$(VSIM) -c -do "do scripts/compile_mem.do;quit -f"

compile_wb: 
	$(VSIM) -c -do "do scripts/compile_wb.do;quit -f"

clean:
	rm -fr work
	rm -f transcript
	rm -f *.wlf
	rm -f modelsim.ini

.PHONY: clean
.PHONY: compile

