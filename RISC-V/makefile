TARGET = hello_world

ASFLAGS = -march=rv64gcv
LDFLAGS = 

AS = riscv64-linux-gnu-as
LD = riscv64-linux-gnu-ld
ifeq ($(shell uname -s), Darwin)
	AS = riscv64-unknown-linux-gnu-as
	LD = riscv64-unknown-linux-gnu-ld
endif

SOURCE = $(wildcard *.S)
OBJS = $(patsubst %.S,%.o,$(SOURCE))

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $(TARGET) $<
	chmod +x $(TARGET)
	sudo scp -O $(TARGET) root@192.168.42.1:/root/
	@rm -rf *.o
	@rm -rf $(OBJS)
	@rm -rf $(TARGET)

%.o: %.S
	$(AS) $(ASFLAGS) -o $@ $<

.PHONY: clean
clean:
	@rm -rf *.o
	@rm -rf $(OBJS)
	@rm -rf $(TARGET)
