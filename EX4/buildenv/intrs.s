	.file	1 "intrs.c"
	.section .mdebug.abi32
	.previous
	.gnu_attribute 4, 1
	.globl	cnt
	.section	.sbss,"aw",@nobits
	.align	2
	.type	cnt, @object
	.size	cnt, 4
cnt:
	.space	4
	.rdata
	.align	2
$LC0:
	.ascii	"!\000"
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
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$fp,24($sp)
	move	$fp,$sp
	li	$2,-1			# 0xffffffffffffffff
	sw	$2,%gp_rel(__exception_retry)($28)
	j	$L3
	nop

$L4:
	nop
$L3:
	lw	$2,%gp_rel(cnt)($28)
	nop
	sw	$2,16($fp)
	lw	$2,%gp_rel(cnt)($28)
	nop
	addiu	$2,$2,1
	sw	$2,%gp_rel(cnt)($28)
	lw	$2,16($fp)
	nop
	addiu	$3,$2,1
	lw	$2,%gp_rel(cnt)($28)
	nop
	beq	$3,$2,$L4
	nop

	lui	$2,%hi($LC0)
	addiu	$4,$2,%lo($LC0)
	jal	puts
	nop

	j	$L3
	nop

	.set	macro
	.set	reorder
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 4.5.3"
