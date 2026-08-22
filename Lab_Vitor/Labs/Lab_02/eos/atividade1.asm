# -- LOADS --
lw x10, a
lw x11, b
# =======================================
add x12, x10, x0
blt x11, x12, SOMA
beq x0, x0, FIM      # Jump.
SOMA:
add x12, x10, x11 
FIM:
sw x12, m            # O Save fica aqui pois mesmo se for para a função SOMA, ele ainda vai ler essa linha.
halt
# =======================================
a: .word 6
b: .word 15
m: .word 0
