compile:
	@nasm -f elf64 main.asm -o main.o
	@ld main.o -o main
	@rm -f main.o
	@./main

clean:
	@rm -f main.o
	@rm -f main
