TARGET = main

AS = nasm
LD = ld

AS_FLAGS = -o build/$(TARGET).o -f elf64
LD_FLAGS = -o build/$(TARGET)

all:
	$(AS) $(AS_FLAGS) src/$(TARGET).asm
	$(LD) $(LD_FLAGS) build/$(TARGET).o

.PHONY: clean
clean:
	@rm -rf *.o
	@rm -rf $(OBJS)
	@rm -rf $(TARGET)
