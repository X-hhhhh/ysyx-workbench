#build options, which also need to define in macro.h to enable
#CONFIG_DIFFTEST = 1;

#address of ysyxSoC
SOC_HOME = $(NEMU_HOME)/../ysyxSoC

#name of top module
TOPNAME = ysyxSoCFull

VERILATOR = verilator

#build address
BUILD_DIR = ./build/verilator

#address for storing files after building
OBJ_DIR = $(BUILD_DIR)/obj_dir

#address of executable file
BIN = $(BUILD_DIR)/$(TOPNAME)

#compilation options
VERILATOR_FLAGS += -O2 #-Wall
VERILATOR_FLAGS += --Mdir $(OBJ_DIR)
VERILATOR_FLAGS += --trace-fst
VERILATOR_FLAGS += --top-module $(TOPNAME)
VERILATOR_FLAGS += --cc --exe -o $(abspath $(BIN))
VERILATOR_FLAGS += --Wno-UNUSEDSIGNAL
VERILATOR_FLAGS += --Wno-PINCONNECTEMPTY
VERILATOR_FLAGS += --build
VERILATOR_FLAGS += --timescale "1ns/1ns" --no-timing
VERILATOR_FLAGS += --autoflush

#include verilog files
VERILATOR_FLAGS += -I$(SOC_HOME)/perip/uart16550/rtl
VERILATOR_FLAGS += -I$(SOC_HOME)/perip/spi/rtl

CFLAGS = -O2 -MMD -Wall
CFLAGS += -I$(NPC_HOME)/csrc/include
LDFLAGS = -lreadline -ldl

#search for files
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v" -or -name "*.sv")
VSRCS += $(shell find $(abspath $(SOC_HOME)/perip) -name "*.v")
VSRCS += $(SOC_HOME)/build/ysyxSoCFull.v
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cpp")

#disasm's dependency
CFLAGS += -I$(NEMU_HOME)/tools/capstone/repo/include
LIBCAPSTONE = $(NEMU_HOME)/tools/capstone/repo/libcapstone.so.5
csrc/disasm.c: $(LIBCAPSTONE)
$(LIBCAPSTONE):
	$(MAKE) -C $(NEMU_HOME)/tools/capstone

#difftest's dependency
ifdef CONFIG_DIFFTEST
DIFF_REF_SO = $(NEMU_HOME)/build/riscv32-nemu-interpreter-so
$(DIFF_REF_SO):
	$(MAKE) -C $(NEMU_HOME) app
override ARGS += --diff=$(DIFF_REF_SO)
endif

run: $(DIFF_REF_SO)
	@echo "-------- VERILATE --- AND --- BUILD --------"
	@rm -rf $(OBJ_DIR)
	@mkdir -p $(OBJ_DIR)

	@$(VERILATOR) $(VERILATOR_FLAGS) $(VSRCS) $(CSRCS) -CFLAGS "$(CFLAGS)" -LDFLAGS "$(LDFLAGS)"
	@$(BIN) $(ARGS) $(IMG) #--trace

	@rm -rf $(BUILD_DIR)/logs
	@mkdir -p $(BUILD_DIR)/logs
	
	@#gtkwave wave.fst

	@echo "------------------ END ---------------------"

gdb: $(DIFF_REF_SO)
	@rm -rf $(OBJ_DIR)
	@mkdir -p $(OBJ_DIR)

	@$(VERILATOR) $(VERILATOR_FLAGS) $(VSRCS) $(CSRCS) -CFLAGS "$(CFLAGS) -g" -LDFLAGS "$(LDFLAGS) -g" --gdbbt --debug
	gdb --args $(BIN) $(ARGS) $(IMG)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run gdb clean $(DIFF_REF_SO)

include ../Makefile

