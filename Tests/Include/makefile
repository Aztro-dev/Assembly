compile:
	@nasm -f elf64 main.asm -o main.o
	@nasm -f elf64 include.asm -o include.o
	@ld -o main include.o main.o
	@rm main.o
	@rm include.o

clean:
	@rm -f main.o
	@rm -f include.o

