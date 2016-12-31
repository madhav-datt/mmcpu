# Function calls and return statements
#

main:
	addi $a0, $0, 14534
	jal funct
	addi $s0, $v0, 0
	j done

funct:
	nor $t0, $0, $0
	xor $v0, $a0, $t0
	jr $ra
			
done:

