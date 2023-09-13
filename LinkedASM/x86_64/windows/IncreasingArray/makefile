compile:
	@nasm -f win64 increasing_array.asm
	@g++ main.cpp -o main -masm=intel increasing_array.obj
	@rm -f increasing_array.obj

clean:
	@rm -f main.exe
	@rm -f increasing_array.obj
