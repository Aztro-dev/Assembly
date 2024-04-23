main: main.o
	ld -o main main.o -dynamic-linker /lib64/ld-linux-x86-64.so.2 -L./raylib/ -lc -lraylib -lm

main.o: main.asm
	nasm -f elf64 main.asm

clean:
	rm -f main.o
	rm -f main
