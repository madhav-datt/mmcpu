# Switch case program
# Test conditional branching
main:
	addi $s0, $0, 50
	j case20

# switch on variable stored in $s0
case20:
	addi $t0, $0, 20 # $t0  20
	bne $s0, $t0, case50 # i != 20
	addi $s1, $0, 2 
	j done # break

case50:
	addi $t0, $0, 50 # $t0 = 50
	bne $s0, $t0, case100 # i != 50
	addi $s1, $0, 3 
	j done # break

case100:
	addi $t0, $0, 100 # $t0  100
	bne $s0, $t0, default # i != 100
	addi $s1, $0, 5
	j done # break

default:
	add $s1, $0, $0 # charge  0

done:
 

