nop

#bne test, imem order:1 2 3 5 6 7 8 9 4 5 6 7 8 9 10...

addi $1, $0, 1  # pc1, r1 = 1
addi $2, $0, 2  # pc2, r2 = 2

bne $1, $2, 1 # pc3, if ($1 != $2) PC = PC + 1 + 1
addi $9, $0, 1 # pc4, r3 = 1
addi $3, $0, 3 # pc5, r3 = 3

bne $1, $1, 1 # pc6, if ($1 != $1) PC = PC + 1 + 1
addi $4, $0, 1 # pc7, r3 = 1
addi $5, $0, 5 # pc8, r3 = 5

bne $4, $9, -6 # pc9, if ($4 != $5) PC = PC + 1 -6