nop

# jal test, imem order:14523678..., $31: 2-6-4
jal 4 # pc1, go to pc4, $31 = 2

addi $1, $0, 1  # pc2, r1 = 1

jal 6 # pc3, go to pc6 (out), $31 = 4

addi $2, $0, 2  # pc4, r2 = 2

jal 2 # pc5, go to pc2, $31 = 6