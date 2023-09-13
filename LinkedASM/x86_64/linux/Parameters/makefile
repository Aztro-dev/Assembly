compile:
	@nasm -f elf64 parameters.asm
	@g++ main.cpp -masm=intel parameters.o -o main

clean:
	@rm -f parameters.o
	@rm -f main.exe
	@rm -f main
