all: compile

compile: 
	/opt/intelFPGA/modelsim_ase/bin/vsim -c -do "do scripts/compile.do;quit -f"

clean:
	rm -fr work
	rm -f transcript
	rm -f *.wlf
	rm -f modelsim.ini

.PHONY: clean
.PHONY: compile
