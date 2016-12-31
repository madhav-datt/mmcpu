main:	addi	$s0, $zero, 40
	addi	$s1, $zero, 23
	sw	$s0, 4($0)
	sw	$s1, 8($t2)
	sw	$s1, 16($0)
	lw	$t5, 4($0)
	lw 	$t6, 8($t2)
	lw	$t7, 16($0)
