compile:
	nasm -f win64 five.asm
	g++ main.cpp -o main -masm=intel five.obj

clean:
	@rm -f main.exe
	@rm -f main
	@rm -f five.obj
	@rm -f main.s
