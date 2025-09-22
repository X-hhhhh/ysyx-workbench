VSRCS = ./vsrc/top.v
CSRCS = ./csrc/sim_main.cpp
VERILATOR_FLAGS = --cc --trace-fst --exe --build

sim:
	verilator -Wall $(VSRCS) $(CSRCS) $(VERILATOR_FLAGS) 
	./obj_dir/Vtop
	gtkwave ./build/logs/cpu_wave.fst

