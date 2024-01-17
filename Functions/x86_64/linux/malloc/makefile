compile:
	@nasm -f elf64 malloc.asm
	@g++ main.cpp -o main -masm=intel malloc.o -no-pie
	@rm -f malloc.o

clean:
	@rm -f malloc.o
	@rm -f main
