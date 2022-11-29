nop

# j test, imem order:14523678...
j 4 # pc1, go to pc4

addi $1, $0, 1  # pc2, r1 = 1

j 6 # pc3, go to pc6 (out)

addi $2, $0, 2  # pc4, r2 = 2

j 2 # pc5, go to pc2
 