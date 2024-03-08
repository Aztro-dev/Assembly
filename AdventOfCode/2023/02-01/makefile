compile:
	@nasm -f elf64 main.asm -o main.o
	@ld -o main main.o
	@rm -f main.o
	
clean:
	@rm -f main
	@rm -f main.o
