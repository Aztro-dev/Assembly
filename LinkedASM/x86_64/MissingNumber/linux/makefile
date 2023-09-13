compile:
	@nasm -f elf64 missing_number.asm
	@g++ main.cpp -o main -masm=intel missing_number.o
	@rm -f missing_number.o

clean:
	@rm -f main
