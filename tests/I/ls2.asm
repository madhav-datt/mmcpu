main:	addi	$s0, $zero, 40
	addi	$s1, $zero, 23
	sw	$s0, 4($0)
	sw	$s1, 16($t2)
	lw	$t5, 4($0)
	lw 	$t6, 16($t2)
