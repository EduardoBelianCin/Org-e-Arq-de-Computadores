lw x10, a #armazenamento das variáveis
lw x11, b
lw x12, a
sw x12, m
blt x11, x12, soma #verifica a condiçao
soma:
    add x12, x10, x11 # soma
    sw x12, m #guarda a variável
halt #encerra o programa

a: .word 25 #variaveis
b: .word 12
m: .word 0
#tabela de valores finais
#a: 6, 14, 25
#b: 15, 7, 12
#m: 21, 21, 37
