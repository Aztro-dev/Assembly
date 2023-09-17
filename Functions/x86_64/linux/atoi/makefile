compile:
	@nasm -f elf64 atoi.asm
	@g++ main.cpp -o main -masm=intel atoi.o -no-pie
	@rm -f atoi.o

clean:
	@rm -f atoi.o
	@rm -f main
