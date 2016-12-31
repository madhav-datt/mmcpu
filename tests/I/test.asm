main:	addi	$1, $zero, 40
	andi	$2, $1, 2567
	ori	$3, $2, 4095
	ori	$4, $zero, 16
	andi	$5, $3, 0
	slti	$12, $1, 4095
	slti 	$13, $1, 17
	xori	$14, $1, 0
	xori	$15, $14, 295
	sw	$1, 4($0)
	sw	$2, 8($t2)
	sw	$2, 16($0)
	lw	$t5, 4($0)
	lw 	$t6, 8($t2)
	lw	$t7, 16($0)
