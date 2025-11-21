
TARGET ?= factorial10
OBJS ?= $(TARGET).cpp

MAKE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKE_DIR := $(dir $(MAKE_PATH))
S19 := $(MAKE_DIR)$(TARGET).s19
MEM_OUT := $(MAKE_DIR)$(TARGET).txt

C_FLAGS = -O0 -march=rv32imzicsr -mabi=ilp32 -Wa,-march=rv32imzicsr -Wextra -Wall -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -fdata-sections -ffunction-sections -fdiagnostics-color=always
ASM_FLAGS = -O0 -march=rv32imzicsr -mabi=ilp32 -Wa,-march=rv32imzicsr -Wextra -Wall -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -fdata-sections -ffunction-sections -fdiagnostics-color=always -DBOOT_M

.PHONY:all
all: clean mkdir build $(TARGET).txt

.PHONY: build
build: $(TARGET)
$(TARGET): $(OBJS)
	riscv32-unknown-elf-gcc $(ASM_FLAGS) -o obj/crt0.boot_M.S.o -c boot/crt0.boot_M.S
	riscv32-unknown-elf-gcc $(C_FLAGS) -o obj/$(TARGET).cpp.s -S $(TARGET).cpp
	riscv32-unknown-elf-gcc -O0 -march=rv32imzicsr -mabi=ilp32 -Wa,-march=rv32imzicsr -Wextra -Wall -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -fdata-sections -ffunction-sections -fdiagnostics-color=always -Wl,-headerpad_max_install_names -Tboot/link.riscv.ld -nostartfiles -Wl,--gc-sections -lm obj/$(TARGET).cpp.s obj/crt0.boot_M.S.o -o $(TARGET).elf
	riscv32-unknown-elf-objcopy --srec-len 1 --output-target=srec $(TARGET).elf $(TARGET).s19
	riscv32-unknown-elf-objdump -h $(TARGET).elf > dump/dump_headers.txt
	riscv32-unknown-elf-objdump -D $(TARGET).elf > dump/dump.txt
	riscv32-unknown-elf-objdump -d $(TARGET).elf > dump/dump_exec.txt

$(TARGET).txt: $(TARGET).s19
	python3 s19_to_bin.py $(S19) $(MEM_OUT)

.PHONY: run
run:
	spike --isa=rv64imafdc -d pk $(TARGET)

.PHONY: mkdir
mkdir: 
	mkdir obj
	mkdir dump

.PHONY: clean
clean:
	rm -rf $(TARGET)
	rm -rf $(TARGET).s19
	rm -rf $(TARGET).txt
	rm -rf $(TARGET).s
	rm -Rf obj
	rm -Rf dump
