compile:
	@nasm -f elf64 main.asm
	@gcc main.o -no-PIE
	@rm -f main.o

clean:
	@rm -f main.o
	@rm -f main
