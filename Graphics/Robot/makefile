main: main.o 
	ld -o build/main build/main.o -dynamic-linker /lib64/ld-linux-x86-64.so.2 -L./raylib/ -lc -lraylib -lm

main.o: src/main.asm
	nasm -f elf64 -gdwarf src/main.asm -o build/main.o

clean:
	rm -r build/*

run: main
	@./build/main

check_size: src/main.asm
	nasm -E src/main.asm -o build/processed.asm
	loc build/processed.asm
	rm build/processed.asm
