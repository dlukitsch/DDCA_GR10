	.file	1 "helloworld.c"
	.section .mdebug.abi32
	.previous
	.gnu_attribute 4, 1
	.rdata
	.align	2
$LC0:
	.ascii	"Hello, MiMi\000"
	.text
	.align	2
	.globl	main
	.set	nomips16
	.ent	main
	.type	main, @function
main:
	.frame	$fp,32,$31		# vars= 8, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$fp,24($sp)
	move	$fp,$sp
	lui	$2,%hi($LC0)
	addiu	$4,$2,%lo($LC0)
	jal	puts
	sw	$0,20($fp)
	j	$L2
$L5:
	sw	$0,16($fp)
	j	$L3
$L4:
	lw	$2,16($fp)
	#nop
	addiu	$2,$2,1
	sw	$2,16($fp)
$L3:
	lw	$3,16($fp)
	li	$2,2949120			# 0x2d0000
	ori	$2,$2,0xc6c0
	slt	$2,$3,$2
	bne	$2,$0,$L4
	lw	$2,20($fp)
	#nop
	addiu	$2,$2,48
	move	$4,$2
	jal	putchar
	lw	$2,20($fp)
	#nop
	addiu	$2,$2,1
	sw	$2,20($fp)
$L2:
	lw	$2,20($fp)
	#nop
	slt	$2,$2,10
	bne	$2,$0,$L5
	li	$4,10			# 0xa
	jal	putchar
	move	$2,$0
	move	$sp,$fp
	lw	$31,28($sp)
	lw	$fp,24($sp)
	addiu	$sp,$sp,32
	j	$31
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 4.5.3"
