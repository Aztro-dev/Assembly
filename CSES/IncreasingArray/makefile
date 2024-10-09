compile: main.asm
	@nasm -f elf64 main.asm -o main.o
	@ld main.o -o main -g
	@rm -f main.o

clean:
	@rm -f main.o
	@rm -f main
