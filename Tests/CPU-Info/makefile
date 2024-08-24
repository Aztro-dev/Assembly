main: main.o 
	ld -o main main.o
	rm main.o

main.o: main.asm
	nasm -f elf64 -gdwarf main.asm -o main.o

clean:
	rm -r build/*

run: main
	./build/main
