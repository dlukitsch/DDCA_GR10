	.file	1 "aluexc.c"
	.section .mdebug.abi32
	.previous
	.gnu_attribute 4, 1
	.rdata
	.align	2
$LC0:
	.ascii	"<<<\000"
	.align	2
$LC1:
	.ascii	">>>\000"
	.text
	.align	2
	.globl	main
	.set	nomips16
	.ent	main
	.type	main, @function
main:
	.frame	$fp,24,$31		# vars= 0, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	addiu	$sp,$sp,-24
	sw	$31,20($sp)
	sw	$fp,16($sp)
	move	$fp,$sp
	sw	$0,%gp_rel(__exception_retry)($28)
	lui	$2,%hi($LC0)
	addiu	$4,$2,%lo($LC0)
	jal	puts
 #APP
 # 11 "aluexc.c" 1
	.set noreorder
	.set noat
	li $1, 0x7fffffff
	addi $1, 1
	nop
	nop
	nop
	
 # 0 "" 2
 # 20 "aluexc.c" 1
	.set noreorder
	.set noat
	li $1, 0x80000000
	addi $1, -1
	nop
	nop
	nop
	
 # 0 "" 2
 # 29 "aluexc.c" 1
	.set noreorder
	.set noat
	li $1, 0x7fffffff
	li $2, 1
	add $1, $2
	nop
	nop
	nop
	
 # 0 "" 2
 # 39 "aluexc.c" 1
	.set noreorder
	.set noat
	li $1, 0x80000000
	li $2, -1
	add $1, $2
	nop
	nop
	nop
	
 # 0 "" 2
 # 49 "aluexc.c" 1
	.set noreorder
	.set noat
	li $1, 0x7fffffff
	li $2, -1
	sub $1, $2
	nop
	nop
	nop
	
 # 0 "" 2
 # 59 "aluexc.c" 1
	.set noreorder
	.set noat
	li $1, 0x80000000
	li $2, 1
	sub $1, $2
	nop
	nop
	nop
	
 # 0 "" 2
 # 69 "aluexc.c" 1
	.set noreorder
	.set noat
	li $1, 0x7fffffff
	addi $1, 1
	addi $1, 1
	nop
	nop
	nop
	
 # 0 "" 2
 # 79 "aluexc.c" 1
	.set noreorder
	.set noat
	li $1, 0x7fffffff
	beqz $0, __aluexcA
	addi $1, 1
	nop
__aluexcA:
	nop
	nop
	nop
	
 # 0 "" 2
 # 91 "aluexc.c" 1
	.set noreorder
	.set noat
	li $1, 0x7fffffff
	beqz $0, __aluexcB
	nop
addi $1, 1
	nop
__aluexcB:
	nop
	nop
	nop
	
 # 0 "" 2
 # 104 "aluexc.c" 1
	.set noreorder
	.set noat
	li $1, 0x7fffffff
	beqz $0, __aluexcC
	nop
nop
addi $1, 1
	nop
__aluexcC:
	nop
	nop
	nop
	
 # 0 "" 2
 # 118 "aluexc.c" 1
	.set noreorder
	.set noat
	li $1, 0x7fffffff
	bnez $0, __aluexcD
	addi $1, 1
	nop
__aluexcD:
	nop
	nop
	nop
	
 # 0 "" 2
 #NO_APP
	lui	$2,%hi($LC1)
	addiu	$4,$2,%lo($LC1)
	jal	puts
	move	$2,$0
	move	$sp,$fp
	lw	$31,20($sp)
	lw	$fp,16($sp)
	addiu	$sp,$sp,24
	j	$31
	.end	main
	.size	main, .-main
	.ident	"GCC: (GNU) 4.5.3"
