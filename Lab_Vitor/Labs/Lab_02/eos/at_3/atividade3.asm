# Versão para testes no COMPSIM (Preciso carregar valores)
# -- LOADS --
lw x19, f
lw x20, g
lw x21, h
lw x22, i
lw x23, j
# =======================================
beq x22, x23, IF
beq x0, x0, ELSE
IF:
add x19, x20, x21
beq x0, x0, FIM
ELSE:
sub x19, x20, x21
FIM:
sw x19, f
halt
# =======================================
f: .word 5
g: .word 40
h: .word 10
i: .word 30
j: .word 5
# Deixei valores aleatórios para testes.
# =======================================
# Versão com só a lógica

beq x22, x23, IF
beq x0, x0, ELSE
IF:
add x19, x20, x21
beq x0, x0, FIM
ELSE:
sub x19, x20, x21
FIM:
halt