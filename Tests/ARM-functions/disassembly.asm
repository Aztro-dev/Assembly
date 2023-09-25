
main:	file format mach-o arm64

Disassembly of section __TEXT,__text:

0000000100003f0c <_test>:
100003f0c: d10043ff    	sub	sp, sp, #16 // For stack alignment
100003f10: b9000fe0    	str	w0, [sp, #12] // [sp + 12] = w0
100003f14: b9000be1    	str	w1, [sp, #8] // [sp + 8] = w1
100003f18: b90007e2    	str	w2, [sp, #4] // [sp + 4] = w2
100003f1c: b9400fe8    	ldr	w8, [sp, #12] // w8 = [sp + 12]
100003f20: b9400be9    	ldr	w9, [sp, #8] // w9 = [sp + 8]
100003f24: 0b090108    	add	w8, w8, w9 // w8 += w9
100003f28: b94007e9    	ldr	w9, [sp, #4] // [sp + 4] = w9
100003f2c: 0b090100    	add	w0, w8, w9 // Register w0 is the return register
100003f30: 910043ff    	add	sp, sp, #16 // realign stack
100003f34: d65f03c0    	ret

0000000100003f38 <_main>:
100003f38: d100c3ff    	sub	sp, sp, #48
100003f3c: a9027bfd    	stp	x29, x30, [sp, #32]
100003f40: 910083fd    	add	x29, sp, #32
100003f44: 52800008    	mov	w8, #0
100003f48: b81f43a8    	stur	w8, [x29, #-12]
100003f4c: b81fc3bf    	stur	wzr, [x29, #-4]
100003f50: 52800c80    	mov	w0, #100
100003f54: 52801901    	mov	w1, #200
100003f58: 52802582    	mov	w2, #300
100003f5c: 97ffffec    	bl	0x100003f0c <_test>
100003f60: b81f83a0    	stur	w0, [x29, #-8]
100003f64: b85f83a9    	ldur	w9, [x29, #-8]
100003f68: aa0903e8    	mov	x8, x9
100003f6c: 910003e9    	mov	x9, sp
100003f70: f9000128    	str	x8, [x9]
100003f74: 90000000    	adrp	x0, 0x100003000 <_main+0x3c>
100003f78: 913e7000    	add	x0, x0, #3996
100003f7c: 94000005    	bl	0x100003f90 <_printf+0x100003f90>
100003f80: b85f43a0    	ldur	w0, [x29, #-12]
100003f84: a9427bfd    	ldp	x29, x30, [sp, #32]
100003f88: 9100c3ff    	add	sp, sp, #48
100003f8c: d65f03c0    	ret

Disassembly of section __TEXT,__stubs:

0000000100003f90 <__stubs>:
100003f90: b0000010    	adrp	x16, 0x100004000 <__stubs+0x4>
100003f94: f9400210    	ldr	x16, [x16]
100003f98: d61f0200    	br	x16

Disassembly of section __TEXT,__cstring:

0000000100003f9c <__cstring>:
100003f9c: 000a6425    	<unknown>

Disassembly of section __TEXT,__unwind_info:

0000000100003fa0 <__unwind_info>:
100003fa0: 00000001    	udf	#1
100003fa4: 0000001c    	udf	#28
100003fa8: 00000000    	udf	#0
100003fac: 0000001c    	udf	#28
100003fb0: 00000000    	udf	#0
100003fb4: 0000001c    	udf	#28
100003fb8: 00000002    	udf	#2
100003fbc: 00003f0c    	udf	#16140
100003fc0: 00000040    	udf	#64
100003fc4: 00000040    	udf	#64
100003fc8: 00003f90    	udf	#16272
100003fcc: 00000000    	udf	#0
100003fd0: 00000040    	udf	#64
		...
100003fe0: 00000003    	udf	#3
100003fe4: 0002000c    	<unknown>
100003fe8: 00020014    	<unknown>
100003fec: 00000000    	udf	#0
100003ff0: 0100002c    	<unknown>
100003ff4: 02001000    	<unknown>
100003ff8: 04000000    	add	z0.b, p0/m, z0.b, z0.b
100003ffc: 00000000    	udf	#0

Disassembly of section __DATA_CONST,__got:

0000000100004000 <__got>:
100004000: 00000000    	udf	#0
100004004: 80000000    	<unknown>
