main:	nor 	$s0, $0, $0
	add	$s1, $s0, $0
	add	$s2, $s0, $s0
	sll	$t1, $s2, 2
	sra	$t2, $s1, 4
	srl	$t3, $t2, 2
	slt     $t0, $t1, $s0
	xor	$s5, $zero, $s2
	or	$t5, $t1, $t0
	and	$t6, $s5, $t3
