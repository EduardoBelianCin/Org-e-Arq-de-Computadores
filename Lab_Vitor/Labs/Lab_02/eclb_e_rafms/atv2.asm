lw x10, a # armazenamento das variáveis
lw x11, b
lw x12, a
sw x12, m

blt x11, x12, soma    # verifica se x11 < x12, se for vai pra soma
beq x0, x0, subtrai   # else, subtrai

soma:
    add x12, x10, x11 # soma A com B e guarda em M
    sw x12, m         # salva a soma em M
    beq x0, x0, else  # pula pra nao subtrair
subtrai:
    sub x12, x10, x11 # subtrai B de A e guarda em M
    sw x12, m         # salva a subtracao em M
else:

halt # encerra o programa

# VARIAVEIS
a: .word 6
b: .word 15
m: .word 0

# tabela de valores finais
# a: 6, 14, 25
# b: 15, 7, 12
# m: -9, 21, 37