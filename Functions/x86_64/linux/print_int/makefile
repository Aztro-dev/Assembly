compile:
	@nasm -f elf64 print_int.asm -o print_int.o
	@ld -o main print_int.o
	@rm -f print_int.o

clean:
	@rm -f print_int.o
	@rm -f main
