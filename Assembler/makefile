TARGET = main

SRC=src
BUILD=build

SRCS=$(wildcard $(SRC)/*.asm)
OBJS=$(SRCS:$(SRC)/%.asm=$(BUILD)/%.o)

AS = nasm
LD = ld

AS_FLAGS = -f elf64
LD_FLAGS = -o $(BUILD)/$(TARGET)


all: $(BUILD)/main.o
	$(LD) $(LD_FLAGS) $^

$(BUILD)/main.o: $(SRC)/main.asm
	$(AS) $(AS_FLAGS) -o $@ $^

.PHONY: clean
clean:
	@rm -rf $(BUILD)/*
	@rm -rf $(TARGET)
