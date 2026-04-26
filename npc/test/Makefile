WORK_DIR := $(shell pwd)
BUILD_DIR := $(WORK_DIR)/build
$(shell mkdir -p $(BUILD_DIR))

CROSS_COMPILE := riscv64-linux-gnu-
GCC := $(CROSS_COMPILE)gcc

CSRC = $(shell find -name "*.c")
ASRC = $(shell find -name "*.s")
LINKER = $(shell find -name "*.ld")

OBJS = $(addprefix $(BUILD_DIR)/, $(addsuffix .o, $(basename $(CSRC))))
OBJS += $(addprefix $(BUILD_DIR)/, $(addsuffix .o, $(basename $(ASRC))))

CFLAGS = -march=rv32i -mabi=ilp32 -static -nostdlib -nodefaultlibs

$(BUILD_DIR)/%.o: %.c
	$(GCC) $(CFLAGS) -c -o $@ $(realpath $<)

$(BUILD_DIR)/%.o: %.s
	$(GCC) $(CFLAGS) -c -o $@ $(realpath $<)

main: $(OBJS)
	$(GCC) $(CFLAGS) -T $(LINKER) -o $@ $^

run: main

clean:
	rm -rf $(BUILD_DIR) 

.PHONY: run clean
