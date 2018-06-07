	.file	1 "exceptions.c"
	.section .mdebug.abi32
	.previous
	.gnu_attribute 4, 1
	.text
	.align	2
	.set	nomips16
	.ent	clear_pending
	.type	clear_pending, @function
clear_pending:
	.frame	$fp,16,$31		# vars= 8, regs= 2/0, args= 0, gp= 0
	.mask	0x40010000,-4
	.fmask	0x00000000,0
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	sw	$16,8($sp)
	move	$fp,$sp
	sw	$4,16($fp)
 #APP
 # 3 "exceptions.c" 1
	mfc0 $16, $13
 # 0 "" 2
 #NO_APP
	sw	$16,0($fp)
	lw	$2,16($fp)
	#nop
	addiu	$2,$2,10
	li	$3,1			# 0x1
	sll	$2,$3,$2
	nor	$2,$0,$2
	lw	$3,0($fp)
	#nop
	and	$2,$3,$2
	sw	$2,0($fp)
	lw	$2,0($fp)
	#nop
 #APP
 # 5 "exceptions.c" 1
	mtc0 $2, $13
 # 0 "" 2
 #NO_APP
	move	$sp,$fp
	lw	$fp,12($sp)
	lw	$16,8($sp)
	addiu	$sp,$sp,16
	j	$31
	.end	clear_pending
	.size	clear_pending, .-clear_pending
	.align	2
	.set	nomips16
	.ent	dump
	.type	dump, @function
dump:
	.frame	$fp,40,$31		# vars= 16, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-40
	sw	$31,36($sp)
	sw	$fp,32($sp)
	move	$fp,$sp
	sw	$4,40($fp)
	sw	$0,16($fp)
	j	$L3
	nop

$L6:
	li	$3,7			# 0x7
	lw	$2,16($fp)
	nop
	subu	$2,$3,$2
	sll	$2,$2,2
	lw	$3,40($fp)
	nop
	srl	$2,$3,$2
	andi	$2,$2,0xf
	sw	$2,20($fp)
	lw	$2,20($fp)
	nop
	slt	$2,$2,10
	beq	$2,$0,$L4
	nop

	lw	$2,20($fp)
	nop
	andi	$2,$2,0x00ff
	addiu	$2,$2,48
	andi	$2,$2,0x00ff
	sll	$2,$2,24
	sra	$2,$2,24
	j	$L5
	nop

$L4:
	lw	$2,20($fp)
	nop
	andi	$2,$2,0x00ff
	addiu	$2,$2,55
	andi	$2,$2,0x00ff
	sll	$2,$2,24
	sra	$2,$2,24
$L5:
	sb	$2,24($fp)
	lb	$2,24($fp)
	nop
	move	$4,$2
	jal	putchar
	nop

	lw	$2,16($fp)
	nop
	addiu	$2,$2,1
	sw	$2,16($fp)
$L3:
	lw	$2,16($fp)
	nop
	slt	$2,$2,8
	bne	$2,$0,$L6
	nop

	move	$sp,$fp
	lw	$31,36($sp)
	lw	$fp,32($sp)
	addiu	$sp,$sp,40
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	dump
	.size	dump, .-dump
	.rdata
	.align	2
$LC0:
	.ascii	"Regs: \000"
	.text
	.align	2
	.set	nomips16
	.ent	dump_regs
	.type	dump_regs, @function
dump_regs:
	.frame	$fp,32,$31		# vars= 8, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$fp,24($sp)
	move	$fp,$sp
	sw	$4,32($fp)
	lui	$2,%hi($LC0)
	addiu	$4,$2,%lo($LC0)
	jal	puts
	nop

	sw	$0,16($fp)
	j	$L8
	nop

$L11:
	lw	$2,16($fp)
	nop
	sll	$2,$2,2
	lw	$3,32($fp)
	nop
	addu	$2,$3,$2
	lw	$2,0($2)
	nop
	move	$4,$2
	jal	dump
	nop

	lw	$2,16($fp)
	nop
	andi	$3,$2,0x3
	li	$2,3			# 0x3
	bne	$3,$2,$L9
	nop

	li	$4,10			# 0xa
	jal	putchar
	nop

	j	$L10
	nop

$L9:
	li	$4,32			# 0x20
	jal	putchar
	nop

$L10:
	lw	$2,16($fp)
	nop
	addiu	$2,$2,1
	sw	$2,16($fp)
$L8:
	lw	$2,16($fp)
	nop
	slt	$2,$2,32
	bne	$2,$0,$L11
	nop

	move	$sp,$fp
	lw	$31,28($sp)
	lw	$fp,24($sp)
	addiu	$sp,$sp,32
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	dump_regs
	.size	dump_regs, .-dump_regs
	.rdata
	.align	2
$LC1:
	.ascii	"EPC: \000"
	.align	2
$LC2:
	.ascii	"NPC: \000"
	.align	2
$LC3:
	.ascii	"Cause: \000"
	.text
	.align	2
	.set	nomips16
	.ent	dump_all
	.type	dump_all, @function
dump_all:
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
	sw	$5,28($fp)
	sw	$6,32($fp)
	sw	$7,36($fp)
	lui	$2,%hi($LC1)
	addiu	$4,$2,%lo($LC1)
	jal	putstring
	nop

	lw	$4,28($fp)
	jal	dump
	nop

	li	$4,10			# 0xa
	jal	putchar
	nop

	lui	$2,%hi($LC2)
	addiu	$4,$2,%lo($LC2)
	jal	putstring
	nop

	lw	$4,24($fp)
	jal	dump
	nop

	li	$4,10			# 0xa
	jal	putchar
	nop

	lui	$2,%hi($LC3)
	addiu	$4,$2,%lo($LC3)
	jal	putstring
	nop

	lw	$4,32($fp)
	jal	dump
	nop

	li	$4,10			# 0xa
	jal	putchar
	nop

	lw	$4,36($fp)
	jal	dump_regs
	nop

	move	$sp,$fp
	lw	$31,20($sp)
	lw	$fp,16($sp)
	addiu	$sp,$sp,24
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	dump_all
	.size	dump_all, .-dump_all
	.globl	__exception_retry
	.section	.sbss,"aw",@nobits
	.align	2
	.type	__exception_retry, @object
	.size	__exception_retry, 4
__exception_retry:
	.space	4
	.rdata
	.align	2
$LC4:
	.ascii	"X#\000"
	.align	2
$LC5:
	.ascii	"I#\000"
	.text
	.align	2
	.globl	__exception_default
	.set	nomips16
	.ent	__exception_default
	.type	__exception_default, @function
__exception_default:
	.frame	$fp,48,$31		# vars= 24, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	.set	noreorder
	.set	nomacro
	addiu	$sp,$sp,-48
	sw	$31,44($sp)
	sw	$fp,40($sp)
	move	$fp,$sp
	sw	$4,48($fp)
	sw	$5,52($fp)
	sw	$6,56($fp)
	sw	$7,60($fp)
	lw	$2,56($fp)
	nop
	srl	$2,$2,2
	andi	$2,$2,0xf
	sw	$2,24($fp)
	lw	$2,24($fp)
	nop
	beq	$2,$0,$L14
	nop

	lw	$2,24($fp)
	nop
	sltu	$2,$2,10
	beq	$2,$0,$L15
	nop

	lw	$2,24($fp)
	nop
	andi	$2,$2,0x00ff
	addiu	$2,$2,48
	andi	$2,$2,0x00ff
	sll	$2,$2,24
	sra	$2,$2,24
	j	$L16
	nop

$L15:
	lw	$2,24($fp)
	nop
	andi	$2,$2,0x00ff
	addiu	$2,$2,55
	andi	$2,$2,0x00ff
	sll	$2,$2,24
	sra	$2,$2,24
$L16:
	sb	$2,28($fp)
	lui	$2,%hi($LC4)
	addiu	$4,$2,%lo($LC4)
	jal	putstring
	nop

	lb	$2,28($fp)
	nop
	move	$4,$2
	jal	putchar
	nop

	li	$4,10			# 0xa
	jal	putchar
	nop

	lw	$4,52($fp)
	jal	dump
	nop

	li	$4,10			# 0xa
	jal	putchar
	nop

	lw	$4,48($fp)
	jal	dump
	nop

	li	$4,10			# 0xa
	jal	putchar
	nop

	lw	$4,56($fp)
	jal	dump
	nop

	li	$4,10			# 0xa
	jal	putchar
	nop

	lw	$2,%gp_rel(__exception_retry)($28)
	nop
	sw	$2,32($fp)
	lw	$2,32($fp)
	nop
	bgez	$2,$L17
	nop

$L18:
	j	$L18
	nop

$L17:
	lw	$2,%gp_rel(__exception_retry)($28)
	j	$L19
	nop

$L14:
	li	$2,88			# 0x58
	sb	$2,20($fp)
	lw	$2,56($fp)
	nop
	srl	$2,$2,10
	andi	$2,$2,0x1f
	sw	$2,24($fp)
	sw	$0,16($fp)
	j	$L20
	nop

$L23:
	li	$3,1			# 0x1
	lw	$2,16($fp)
	nop
	sll	$2,$3,$2
	move	$3,$2
	lw	$2,24($fp)
	nop
	and	$2,$3,$2
	beq	$2,$0,$L21
	nop

	lw	$2,16($fp)
	nop
	andi	$2,$2,0x00ff
	addiu	$2,$2,48
	andi	$2,$2,0x00ff
	sb	$2,20($fp)
	lw	$4,16($fp)
	jal	clear_pending
	nop

	j	$L22
	nop

$L21:
	lw	$2,16($fp)
	nop
	addiu	$2,$2,1
	sw	$2,16($fp)
$L20:
	lw	$2,16($fp)
	nop
	slt	$2,$2,5
	bne	$2,$0,$L23
	nop

$L22:
	lui	$2,%hi($LC5)
	addiu	$4,$2,%lo($LC5)
	jal	putstring
	nop

	lb	$2,20($fp)
	nop
	move	$4,$2
	jal	putchar
	nop

	li	$4,10			# 0xa
	jal	putchar
	nop

	lw	$3,52($fp)
	lw	$2,48($fp)
	nop
	beq	$3,$2,$L24
	nop

	lw	$4,52($fp)
	jal	dump
	nop

	li	$4,10			# 0xa
	jal	putchar
	nop

	lw	$4,48($fp)
	jal	dump
	nop

	li	$4,10			# 0xa
	jal	putchar
	nop

$L24:
	lw	$3,56($fp)
	li	$2,2147418112			# 0x7fff0000
	ori	$2,$2,0xffff
	and	$2,$3,$2
	move	$4,$2
	jal	dump
	nop

	li	$4,10			# 0xa
	jal	putchar
	nop

	li	$2,1			# 0x1
$L19:
	move	$sp,$fp
	lw	$31,44($sp)
	lw	$fp,40($sp)
	addiu	$sp,$sp,48
	j	$31
	nop

	.set	macro
	.set	reorder
	.end	__exception_default
	.size	__exception_default, .-__exception_default
	.ident	"GCC: (GNU) 4.5.3"
