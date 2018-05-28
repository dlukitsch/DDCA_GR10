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
	j loop
	addi $1, $1, 1
	addi $2, $2, 1
	nop

exit:
  
	.end	_start
	.size	_start, .-_start
