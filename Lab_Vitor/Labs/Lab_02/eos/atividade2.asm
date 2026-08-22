# -- LOADS --
lw x10, a
lw x11, b
lw x12, m
# =======================================
blt x11, x12, IF
beq x0, x0, ELSE
IF:
add x12, x10, x11
beq x0, x0,FIM
ELSE:
sub x12, x10, x11
FIM:
sw x12, m           # Não precisa colocar o sw no ''ELSE'' afinal por não ter jumps, ele virá direto para cá.
halt
# =======================================
a: .word 6
b: .word 15
m: .word 0