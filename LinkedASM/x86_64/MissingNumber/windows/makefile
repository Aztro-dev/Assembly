compile:
	@nasm -f win64 missing_number.asm
	@g++ main.cpp -o main -masm=intel missing_number.obj
	@rm -f missing_number.obj

clean:
	@rm -f main.exe
