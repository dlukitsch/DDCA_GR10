;
; Author: Jan Nausner <e01614835@student.tuwien.ac.at>
;
; A simple fibonacci program
; The number of iterations is specified in register $4
; The result will be in $1
;

        .set    noreorder
	.set	noat

        .text
        .align  2
        .globl  _start
        .ent    _start
                
_start:
	addi $1, $0, 1          ; F_n-1
	addi $2, $0, 1          ; F_n-2
	addi $3, $0, 0          ; loop counter
	addi $4, $0, 5          ; loop bound
	
$loop:
        beq $3, $4, $exit       ; loop condition
        add $5, $1, $0          ; store F_n-1 value to temp register
        add $1, $2, $5          ; F_n=F_n-1 + F_n-2
        add $2, $5, $0          ; F_n-2 := F_n-1   
        addi $3, $3, $1         ; counter := counter + 1
        j $loop                 ; jump to loop entry

$exit:
  
	.end	_start
	.size	_start, .-_start
