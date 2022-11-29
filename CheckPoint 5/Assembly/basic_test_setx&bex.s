nop

# setx test
setx -1 # $30 = -1
setx 1 # $30 = 1

# bex $rs != 0 pc go to r1 = 2
bex 5 # if ($rstatus != 0) PC = 5

addi $1, $0, 1  # r1 = 1

addi $1, $0, 2  # r1 = 2 #pc=5

setx 0 # $30 = 0

# bex $rs == 0 pc go to r1 = 1, then r2 = 2
bex 9 # if ($rstatus != 0) PC = 9

addi $1, $0, 1  # r1 = 1

addi $2, $0, 2  # r2 = 2