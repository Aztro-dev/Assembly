compile: main.asm
	@nasm -f elf64 main.asm -o main.o
	@ld main.o -o main -g
	@rm -f main.o

scalar: scalar.asm
	@nasm -f elf64 scalar.asm -o scalar.o
	@ld scalar.o -o scalar -g
	@rm -f scalar.o

clean:
	@rm -f main.o
	@rm -f main
	@rm -f scalar.o
	@rm -f scalar
