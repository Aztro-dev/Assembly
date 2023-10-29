compile:
	@nasm -f elf64 main.asm
	@ld main.o -g -o main
	@rm -f main.o

clean:
	@rm -f main.o
	@rm -f main
	@rm -f gift1.out
