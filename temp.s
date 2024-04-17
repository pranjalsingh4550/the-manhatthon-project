	.file	"temp.c"
	.text
	.section	.rodata
.LC0:
	.string	"%s wordd\n"
.LC1:
	.string	"%d\n"
.LC2:
	.string	"%d\n\n\n\n\n\n\n"
.LC3:
	.string	"%d %d\n\n\n\n\n\n\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movabsq	$8026294373768721251, %rax
	movq	%rax, -30(%rbp)
	movl	$1702064757, -22(%rbp)
	movw	$10, -18(%rbp)
	leaq	-30(%rbp), %rax
	movq	%rax, %rsi
	leaq	.LC0(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$971, %esi
	leaq	.LC1(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$971, %esi
	leaq	.LC2(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movl	$1020, %edx
	movl	$971, %esi
	leaq	.LC3(%rip), %rax
	movq	%rax, %rdi
	movl	$0, %eax
	call	printf@PLT
	movq	-8(%rbp), %rax
	andl	$8, %eax
	movq	%rax, -16(%rbp)
	movq	-8(%rbp), %rax
	orq	-16(%rbp), %rax
	testq	%rax, %rax
	je	.L2
	movq	$55, -8(%rbp)
	jmp	.L3
.L2:
	movq	-16(%rbp), %rax
	notq	%rax
	movq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	je	.L4
	movq	$66, -8(%rbp)
	jmp	.L3
.L4:
	movq	$77, -8(%rbp)
	cmpq	$0, -8(%rbp)
	jne	.L5
	cmpq	$0, -16(%rbp)
	je	.L6
.L5:
	movl	$1, %eax
	jmp	.L7
.L6:
	movl	$0, %eax
.L7:
	cltq
	movq	%rax, -8(%rbp)
.L3:
	movq	-8(%rbp), %rax
	cmpq	-16(%rbp), %rax
	je	.L8
	movq	$5, -8(%rbp)
.L8:
	movq	-16(%rbp), %rax
	movl	%eax, %edx
	movq	-8(%rbp), %rax
	movl	%edx, %ecx
	salq	%cl, %rax
	testq	%rax, %rax
	je	.L9
	movq	$6, -8(%rbp)
.L9:
	movq	-16(%rbp), %rax
	movl	%eax, %edx
	movq	-8(%rbp), %rax
	movl	%edx, %ecx
	sarq	%cl, %rax
	testq	%rax, %rax
	je	.L10
	movq	$7, -8(%rbp)
.L10:
	cmpq	$0, -8(%rbp)
	jne	.L11
	movq	$8, -8(%rbp)
.L11:
	salq	$60, -16(%rbp)
	movq	-16(%rbp), %rax
	orq	%rax, -8(%rbp)
	cmpq	$0, -8(%rbp)
	je	.L12
	cmpq	$0, -16(%rbp)
	je	.L12
	movl	$1, %eax
	jmp	.L13
.L12:
	movl	$0, %eax
.L13:
	cltq
	movq	%rax, -8(%rbp)
	movl	$44, %eax
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
