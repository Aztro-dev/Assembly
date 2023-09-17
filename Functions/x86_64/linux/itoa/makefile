compile:
	@nasm -f elf64 itoa.asm
	@g++ main.cpp -o main -masm=intel itoa.o
	@rm -f itoa.o

clean:
	@rm -f itoa.o
	@rm -f main
