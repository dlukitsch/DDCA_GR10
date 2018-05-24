
#VSIM=~/intelFPGA/17.1/modelsim_ase/linuxaloem/vsim
#VSIM=/opt/intelFPGA/modelsim_ase/bin/vsim
#VSIM=~/intelFPGA_lite/17.1/modelsim_ase/linuxaloem/vsim
VSIM=vsim

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

sim_mem: compile_mem
	$(VSIM) -c -do "do scripts/sim_mem.do;run 1 us;quit -f" 

compile_wb: 
	$(VSIM) -c -do "do scripts/compile_wb.do;quit -f"

sim_wb: compile_wb
	$(VSIM) -c -do "do scripts/sim_wb.do;run 1 us;quit -f" 

compile_pipeline: 
	$(VSIM) -c -do "do scripts/compile_pipeline.do;quit -f"

sim_pipeline: compile_pipeline
	$(VSIM) -do "do scripts/sim_pipeline.do" 

sim_dec_exec:
	$(VSIM) -do "do scripts/sim_dec_exec.do" 

clean:
	rm -fr work
	rm -f transcript
	rm -f *.wlf
	rm -f modelsim.ini

.PHONY: clean
.PHONY: compile

