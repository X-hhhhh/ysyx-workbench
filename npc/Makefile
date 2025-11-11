#name of top module
TOPNAME = top

VERILATOR = verilator

#build address
BUILD_DIR = ./build/verilator

#address for storing files after building
OBJ_DIR = $(BUILD_DIR)/obj_dir

#address of executable file
BIN = $(BUILD_DIR)/$(TOPNAME)

#compilation options
VERILATOR_FLAGS += --Mdir $(OBJ_DIR)
VERILATOR_FLAGS += -O2 -MMD -Wall
VERILATOR_FLAGS += --trace-fst
VERILATOR_FLAGS += --build
VERILATOR_FLAGS += --top-module $(TOPNAME)
VERILATOR_FLAGS += --cc --exe -o $(abspath $(BIN))
VERILATOR_FLAGS += --Wno-UNUSEDSIGNAL

#search for files
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v" -or -name "*.sv")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cpp")

all:
	@echo "Write this Makefile by your self."

run:
	@echo "-------- VERILATE --- AND --- BUILD --------"
	@rm -rf $(OBJ_DIR)
	@mkdir -p $(OBJ_DIR)

	@$(VERILATOR) $(VERILATOR_FLAGS) $(VSRCS) $(CSRCS)
	@$(BIN) $(ARGS) $(IMG) --trace

	@echo
	@echo "-------------------- SIM --------------------"

	@rm -rf $(BUILD_DIR)/logs
	@mkdir -p $(BUILD_DIR)/logs

	@echo
	@echo "-------------------- DONE --------------------"
	
	@#gtkwave wave.fst
	@echo

gdb: 
	@rm -rf $(OBJ_DIR)
	@mkdir -p $(OBJ_DIR)

	@$(VERILATOR) $(VERILATOR_FLAGS) $(VSRCS) $(CSRCS) --gdbbt --debug --gdb
	@gdb -s $(BIN) --args $(BIN) $(ARGS) $(IMG)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run gdb clean

include ../Makefile

