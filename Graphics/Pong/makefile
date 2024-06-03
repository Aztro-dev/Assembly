main: main.o move.o
	ld -o build/main build/main.o -dynamic-linker /lib64/ld-linux-x86-64.so.2 -L./raylib/ -lc -lraylib -lm

main.o: src/main.asm
	nasm -f elf64 src/main.asm -o build/main.o

move.o: src/move.asm
	nasm -f elf64 src/move.asm -o build/move.o

clean:
	rm -r build/*

run: main
	./build/main
