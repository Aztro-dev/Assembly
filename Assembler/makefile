TARGET = main

ASFLAGS = -f elf64
LDFLAGS = -arch x86_64

AS = nasm
LD = ld

SOURCE = $(wildcard *.asm)
OBJS = $(patsubst %.asm,%.o,$(SOURCE))

BUILD_DIR = $(./build/)

$(BUILD_DIR)$(TARGET): $(BUILD_DIR)$(OBJS)
	$(LD) $(LDFLAGS) -o $(BUILD_DIR)$(TARGET) $(BUILD_DIR)$<
	@rm -rf *.o
	@rm -rf $(OBJS)

$(BUILD_DIR)%.o: %.asm
	$(AS) $(ASFLAGS) -o $(BUILD_DIR)$@ $<

.PHONY: clean
clean:
	@rm -rf *.o
	@rm -rf $(OBJS)
	@rm -rf $(TARGET)
