nop

#blt test, imem order:1 2 3 5 6 7 8 9 4 5 6 7 8 9 10...

addi $1, $0, 1  # pc1, r1 = 1
addi $2, $0, 2  # pc2, r2 = 2

blt $1, $2, 3 # pc3, if ($1 < $2) PC = PC + 1 + 1
addi $9, $0, 9 # pc4, r9 = 9
addi $3, $0, 3 # pc5, r3 = 3
addi $4, $0, 4 # pc5, r4 = 4
addi $6, $0, 6 # pc5, r6 = 6

blt $1, $1, 1 # pc6, if ($1 < $1) PC = PC + 1 + 1
addi $4, $0, 1 # pc7, r4 = 1
addi $5, $0, 5 # pc8, r5 = 5

blt $9, $4, -6 # pc9, if ($4 < $5) PC = PC + 1 -6
 