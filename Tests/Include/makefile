compile:
	@nasm -f elf64 main.asm -o main.o
	@nasm -f elf64 include.asm -o include.o
	@ld main.o include.o -o main
	@rm main.o
	@rm include.o

clean:
	@rm -f main.o
	@rm -f include.o
	@rm -f main
