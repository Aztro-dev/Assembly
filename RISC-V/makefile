ASFLAGS = -march=rv64gcv -o main.o
LDFLAGS = -o main

AS = riscv64-linux-gnu-as
LD = riscv64-linux-gnu-ld

all: main.S
	$(AS) $(ASFLAGS) main.S
	$(LD) $(LDFLAGS) main.o
	chmod +x main
	scp -O main root@192.168.42.1:/root/

clean:
	rm -f main.o
	rm -f main
