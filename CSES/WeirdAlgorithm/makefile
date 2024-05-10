main: main.o
	@ld main.o -o main
	@rm main.o

main.o: main.asm
	@nasm -f elf64 main.asm -o main.o

clean:
	@rm -f main
	@rm -f main.o
