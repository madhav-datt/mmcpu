main:	nor 	$s0, $0, $0
	xor	$s1, $s0, $0
	xor	$s2, $s0, $s0
	nor	$s3, $s2, $s1
	or 	$s4, $s3, $s2
	and 	$s5, $s4, $s3
	sra 	$s6, $s5, 2
	slt 	$t0, $s6, $s5
	and 	$t1, $t0, $s6
	xor 	$t2, $t0, $s3
