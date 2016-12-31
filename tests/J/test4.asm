# Calculate difference between sums of arguments
# Test function calls, linking, return statements etc. with lw and sw
# 

main:
	# Args = 2,3,4,5
	addi $a0, $0, 2 
	addi $a1, $0, 3 
	addi $a2, $0, 4 
	addi $a3, $0, 5
	jal diffofsums 
	add $s0, $v0, $0
	j done

diffofsums:
	addi $sp, $sp, 12
	sw $s0, 8($sp) 
	sw $t0, 4($sp) 
	sw $t1, 0($sp) 
	
	add $t0, $a0, $a1 
	add $t1, $a2, $a3 
	# result  (a0 + a1) - (a2 + a3)
	sub $s0, $t0, $t1 
	add $v0, $s0, $0 
	
	lw $t1, 0($sp) 
	lw $t0, 4($sp) 
	lw $s0, 8($sp) 
	
	addi $sp, $sp, 12 
	jr $ra 

done:

