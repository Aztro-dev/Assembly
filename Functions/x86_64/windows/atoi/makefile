compile:
	@nasm -f win64 atoi.asm
	@g++ main.cpp -o main -masm=intel atoi.obj

clean:
	@rm -f atoi.obj
	@rm -f main.exe
