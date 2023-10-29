compile:
	@nasm -f elf64 main.asm
	@ld main.o -o main -g
	@rm -f main.o

clean:
	@rm -f main.o
	@rm -f main
	@rm -f gift1.out
