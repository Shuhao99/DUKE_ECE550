nop

# jr test, imem order:14523678..., $31: 2
jal 4 # pc1, go to pc4, $31 = 2

addi $1, $0, 1  # pc2, r1 = 1

j 6 # pc3, go to pc6 (out)

addi $2, $0, 2  # pc4, r2 = 2

jr $31 # pc5, go to pc in $31 = 2
 