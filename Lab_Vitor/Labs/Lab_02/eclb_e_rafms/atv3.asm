lw x19, f #armazenamento das variáveis
lw x20, g
lw x21, h
lw x22, i
lw x23, j

beq x22, x23, soma    # verifica i == j
beq x0, x0, subtrai   # else, subtrai

soma:
    add x19, x20, x21 # soma G com H e guarda em F
    sw x19, f         # salva a soma em F
    beq x0, x0, else  # pula pra nao subtrair
subtrai:
    sub x19, x20, x21 # subtrai H de G e guarda em F
    sw x19, f         # salva a subtracao em F
else:

halt # encerra o programa

# VARIAVEIS
f: .word 0
g: .word 6
h: .word 15
i: .word 1
j: .word 1

# tabela de valores finais
# f: 21, 7, 37
# g: 6, 14, 25
# h: 15, 7, 12
# i: 1, 2, 4
# j: 1, 3, 4