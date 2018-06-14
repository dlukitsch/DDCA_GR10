#
# Author: Jan Nausner <e01614835@student.tuwien.ac.at>
#
# A simple fibonacci program
# The number of iterations is specified in register $4
# The result will be in $1
#

        .set    noreorder
	.set	noat

        .text
        .align  2
        .globl  _start
        .ent    _start
                
_start:	
loop:
	addi $1, $0, 7
	addi $2, $0, 5
	and $1, $2, $1
	nop
	nop
exit:
  
	.end	_start
	.size	_start, .-_start
