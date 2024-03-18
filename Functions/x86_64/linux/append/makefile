compile:
	@nasm -f elf64 append.asm
	@g++ main.cpp -o main -masm=intel append.o -no-pie
	@rm -f append.o

clean:
	@rm -f append.o
	@rm -f main
