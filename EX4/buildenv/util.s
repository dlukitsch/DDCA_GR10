	.file	1 "util.c"
	.section .mdebug.abi32
	.previous
	.gnu_attribute 4, 1
	.text
	.align	2
	.globl	getchar
	.set	nomips16
	.ent	getchar
	.type	getchar, @function
getchar:
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-8
	sw	$fp,4($sp)
	move	$fp,$sp
	nop
$L2:
	li	$2,-8			# 0xfffffffffffffff8
	lbu	$2,0($2)
	nop
	sll	$2,$2,24
	sra	$2,$2,24
	andi	$2,$2,0x00ff
	andi	$2,$2,0x2
	beq	$2,$0,$L2
	nop

	li	$2,-4			# 0xfffffffffffffffc
	lbu	$2,0($2)
	nop
	sll	$2,$2,24
	sra	$2,$2,24
	move	$sp,$fp
	lw	$fp,4($sp)
	addiu	$sp,$sp,8
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	getchar
	.size	getchar, .-getchar
	.align	2
	.globl	putchar
	.set	nomips16
	.ent	putchar
	.type	putchar, @function
putchar:
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-8
	sw	$fp,4($sp)
	move	$fp,$sp
	sw	$4,8($fp)
	nop
$L4:
	li	$2,-8			# 0xfffffffffffffff8
	lbu	$2,0($2)
	nop
	sll	$2,$2,24
	sra	$2,$2,24
	andi	$2,$2,0x00ff
	andi	$2,$2,0x1
	beq	$2,$0,$L4
	nop

	li	$2,-4			# 0xfffffffffffffffc
	lw	$3,8($fp)
	nop
	sll	$3,$3,24
	sra	$3,$3,24
	sb	$3,0($2)
	lw	$2,8($fp)
	move	$sp,$fp
	lw	$fp,4($sp)
	addiu	$sp,$sp,8
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	putchar
	.size	putchar, .-putchar
	.align	2
	.globl	putstring
	.set	nomips16
	.ent	putstring
	.type	putstring, @function
putstring:
	.frame	$fp,24,$31		# vars= 0, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-24
	sw	$31,20($sp)
	sw	$fp,16($sp)
	move	$fp,$sp
	sw	$4,24($fp)
	j	$L6
	nop

$L7:
	lw	$2,24($fp)
	nop
	lb	$2,0($2)
	lw	$3,24($fp)
	nop
	addiu	$3,$3,1
	sw	$3,24($fp)
	move	$4,$2
	jal	putchar
	nop

$L6:
	lw	$2,24($fp)
	nop
	lb	$2,0($2)
	nop
	bne	$2,$0,$L7
	nop

	move	$2,$0
	move	$sp,$fp
	lw	$31,20($sp)
	lw	$fp,16($sp)
	addiu	$sp,$sp,24
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	putstring
	.size	putstring, .-putstring
	.align	2
	.globl	puts
	.set	nomips16
	.ent	puts
	.type	puts, @function
puts:
	.frame	$fp,24,$31		# vars= 0, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-24
	sw	$31,20($sp)
	sw	$fp,16($sp)
	move	$fp,$sp
	sw	$4,24($fp)
	lw	$4,24($fp)
	jal	putstring
	nop

	li	$4,10			# 0xa
	jal	putchar
	nop

	move	$2,$0
	move	$sp,$fp
	lw	$31,20($sp)
	lw	$fp,16($sp)
	addiu	$sp,$sp,24
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	puts
	.size	puts, .-puts
	.align	2
	.globl	memcpy
	.set	nomips16
	.ent	memcpy
	.type	memcpy, @function
memcpy:
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-8
	sw	$fp,4($sp)
	move	$fp,$sp
	sw	$4,8($fp)
	sw	$5,12($fp)
	sw	$6,16($fp)
	j	$L10
	nop

$L11:
	lw	$2,8($fp)
	lw	$3,12($fp)
	nop
	lb	$3,0($3)
	nop
	sb	$3,0($2)
	lw	$2,8($fp)
	nop
	addiu	$2,$2,1
	sw	$2,8($fp)
	lw	$2,12($fp)
	nop
	addiu	$2,$2,1
	sw	$2,12($fp)
$L10:
	lw	$2,16($fp)
	nop
	sltu	$2,$0,$2
	andi	$2,$2,0x00ff
	lw	$3,16($fp)
	nop
	addiu	$3,$3,-1
	sw	$3,16($fp)
	bne	$2,$0,$L11
	nop

	lw	$2,8($fp)
	move	$sp,$fp
	lw	$fp,4($sp)
	addiu	$sp,$sp,8
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	memcpy
	.size	memcpy, .-memcpy
	.align	2
	.globl	strlen
	.set	nomips16
	.ent	strlen
	.type	strlen, @function
strlen:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	sw	$0,0($fp)
	j	$L13
	nop

$L14:
	lw	$2,0($fp)
	nop
	addiu	$2,$2,1
	sw	$2,0($fp)
$L13:
	lw	$2,16($fp)
	nop
	lb	$2,0($2)
	nop
	sltu	$2,$0,$2
	andi	$2,$2,0x00ff
	lw	$3,16($fp)
	nop
	addiu	$3,$3,1
	sw	$3,16($fp)
	bne	$2,$0,$L14
	nop

	lw	$2,0($fp)
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	strlen
	.size	strlen, .-strlen
	.align	2
	.globl	strcmp
	.set	nomips16
	.ent	strcmp
	.type	strcmp, @function
strcmp:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	sw	$5,20($fp)
	j	$L19
	nop

$L20:
	nop
$L19:
	lw	$2,16($fp)
	nop
	lbu	$2,0($2)
	nop
	sb	$2,0($fp)
	lw	$2,16($fp)
	nop
	addiu	$2,$2,1
	sw	$2,16($fp)
	lw	$2,20($fp)
	nop
	lbu	$2,0($2)
	nop
	sb	$2,1($fp)
	lw	$2,20($fp)
	nop
	addiu	$2,$2,1
	sw	$2,20($fp)
	lb	$2,0($fp)
	nop
	bne	$2,$0,$L16
	nop

	lb	$2,1($fp)
	nop
	bne	$2,$0,$L16
	nop

	move	$2,$0
	j	$L17
	nop

$L16:
	lb	$3,0($fp)
	lb	$2,1($fp)
	nop
	subu	$2,$3,$2
	sw	$2,4($fp)
	lw	$2,4($fp)
	nop
	beq	$2,$0,$L20
	nop

	lw	$2,4($fp)
$L17:
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	strcmp
	.size	strcmp, .-strcmp
	.ident	"GCC: (GNU) 4.5.3"
