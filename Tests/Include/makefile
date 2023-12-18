compile:
	@nasm -f elf64 main.asm -o main.o
	@nasm -f elf64 include.asm -o include.o
	@gcc -march=x86-64 -o main main.o include.o 
	@rm main.o
	@rm include.o

clean:
	@rm -f main.o
	@rm -f include.o
