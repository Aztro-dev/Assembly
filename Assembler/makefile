TARGET = main

SRC=src
BUILD=build

SRCS=$(wildcard $(SRC)/*.asm)
OBJS=$(SRCS:$(SRC)/%.asm=$(BUILD)/%.o)

AS = nasm
LD = ld

AS_FLAGS = -f elf64
LD_FLAGS = -o $(BUILD)/$(TARGET)


all: $(OBJS)
	$(LD) $(LD_FLAGS) $^

compile: $(OBJS)

$(BUILD)/%.o: $(SRC)/%.asm
	$(AS) $(AS_FLAGS) -o $@ $^

run: $(BUILD)/$(TARGET)
	@./$(BUILD)/$(TARGET) example.S

.PHONY: clean
clean:
	@rm -rf $(BUILD)/*
	@rm -rf $(TARGET)
