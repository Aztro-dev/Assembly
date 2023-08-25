compile:
	@nasm main.asm -f bin -o boot.bin
	@qemu-system-x86_64 boot.bin

clean:
	@rm -f boot.bin
