compile:
	@nasm -f win64 min.asm
	@gcc main.c -o main min.obj
	@rm -f min.obj

clean:
	@rm -f min.obj
	@rm -f main.exe
