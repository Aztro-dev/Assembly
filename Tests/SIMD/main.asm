	;    extern "C" void init_array(float *arr, int n)
	;for (int i=0; i<n; i+=4) {
	;    a[i]=3.4f
	;    a[i+1]=3.4f
	;    a[i+2]=3.4f
	;    a[i+3]=3.4f
	;}

	global init_array

init_array:
	;      rdi points to arr
	;      rsi is n, the array length
	mov    rcx, 0; i
	movaps xmm1, [constant3_4]

	jmp loopcompare

loopstart:
	movaps [rdi+4*rcx], xmm1; init array with xmm1

	add rcx, 4

loopcompare:
	cmp rcx, rsi
	jl  loopstart
	ret

section .data align=16

constant3_4:
	dd 3.4, 3.4, 3.4, 3.4; movaps!

	section .text
	;       extern "C" void add_array(float *arr, int n)
	;for    (int i=0; i<n; i++) a[i]+=1.2f

	global add_array

add_array:
	;      rdi points to arr
	;      rsi is n, the array length
	mov    rcx, 0; i
	movaps xmm1, [constant1_2]

	jmp loopcompare2

loopstart2:
	movaps xmm0, [rdi+4*rcx]; loads arr[i] through arr[i+3]
	addps  xmm0, xmm1
	movaps [rdi+4*rcx], xmm0

	add rcx, 4

loopcompare2:
	cmp rcx, rsi
	jl  loopstart2
	ret

section .data align=16

constant1_2:
	dd 1.2, 1.2, 1.2, 1.2; movaps!
