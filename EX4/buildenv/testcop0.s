        .set    noreorder
	.set	noat

        .text
        .align  2
        .globl  _start
        .ent    _start
                
_start:
		addi $1, $0, 16
		nop
		
		mfc0 $2, $12 #copy status register to reg 2
		mfc0 $3, $13 #copy cause register to reg 3
		mfc0 $4, $13 #copy epc register to reg 4
		mfc0 $5, $13 #copy npc register to reg 5
		nop
		
		addi $2, $0, -1	
		addi $3, $0, -2	
		addi $4, $0, -3	
		addi $5, $0, -4
		nop	
		
		mtc0 $2, $12 #copy reg 2 to status reg
		mtc0 $3, $13 #copy reg 3 to cause reg
		mtc0 $4, $14 #copy reg 4 to epc reg
		mtc0 $5, $15 #copy reg 5 to npc reg
		nop
		
		mfc0 $6, $12 #copy status register to reg 6
		mfc0 $7, $13 #copy cause register to reg 7
		mfc0 $8, $14 #copy epc register to reg 8
		mfc0 $9, $15 #copy npc register to reg 9
		nop
		
		#test alu overflow exception
		li $1, 0x7fffffff
		addi $1, 1
		nop
		nop
		nop

		li $1, 0x80000000
		addi $1, -1
		nop
		nop
		nop

		li $1, 0x7fffffff
		li $2, 1
		add $1, $2
		nop
		nop
		nop

		li $1, 0x80000000
		li $2, -1
		add $1, $2
		nop
		nop
		nop
		
		li $1, 0x7fffffff
		li $2, -1
		sub $1, $2
		nop
		nop
		nop
		
		li $1, 0x80000000
		li $2, -1
		sub $1, $2
		nop
		nop
		nop
		
		li $1, 0x7fffffff
		addi $1, 1
		addi $1, 1
		nop
		nop
		nop
		
		#ovf in bds, branch taken
		li $1, 0x7fffffff
		beqz $0, __aluexcA
		addi $1, 1
		nop
__aluexcA:	nop
		nop
		nop

		#ovf just outside bds
		li $1, 0x7fffffff
		beqz $0, __aluexcB
		nop
		addi $1, 1
		nop
__aluexcB:	nop
		nop
		nop
	
		#ovf outside bds
		li $1, 0x7fffffff
		beqz $0, __aluexcC
		nop
		nop
		addi $1, 1
		nop
__aluexcC:	nop
		nop
		nop
	
		#ovf in bds, branch noz taken
		li $1, 0x7fffffff
		bnez $0, __aluexcD
		addi $1, 1
		nop
__aluexcD:	nop
		nop
		nop
	
	.end	_start
	.size	_start, .-_start
