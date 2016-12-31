# Recursive sum of natural numbers
#

main:
	addi $sp, $sp, 128
	addi $s0, $0, 3  # number = 42
	add $a0, $s0, $0
	jal sum
	add $s1, $v0, $0
	j done

sum:
	addi $sp, $sp, -20
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	
	bne $a0, $0, notzero
	addi $v0, $0, 0
	j return
	
notzero:
	lw $t1, 0($sp)
	addi $a0, $t1, -1
	jal sum
	lw $t1, 0($sp)
	add $v0, $v0, $t1
	j return	

return:
	lw $ra, 4($sp)
	addi $sp, $sp, 20
	jr $ra
	
done:

