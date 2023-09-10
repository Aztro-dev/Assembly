compile:
	yasm -g dwarf2 -f elf64 main.asm
	gcc main.cpp -o main -no-pie main.o

clean:
	rm main.o
	rm main
