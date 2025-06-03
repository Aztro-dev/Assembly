compile: main.asm
	@nasm -f elf64 main.asm -o main.o
	@ld main.o -o main -g
	@rm -f main.o

scalar: scalar.asm
	@nasm -f elf64 scalar.asm -o scalar.o
	@ld scalar.o -o scalar -g
	@rm -f scalar.o

benchmark: main.asm scalar.asm benchmark.c
	@nasm -f elf64 main.asm -o avx.o
	@nasm -f elf64 scalar.asm -o scalar.o
	@gcc benchmark.c -no-pie -o benchmark avx.o scalar.o
	@rm -f avx.o
	@rm -f scalar.o

clean:
	@rm -f main.o
	@rm -f main
	@rm -f avx.o
	@rm -f benchmark
	@rm -f scalar.o
	@rm -f scalar
