compile:
	@nasm -f win64 main.asm
	@gcc main.obj -o main
	@rm -f main.obj

clean:
	@rm -f main.obj
	@rm -f main.exe
