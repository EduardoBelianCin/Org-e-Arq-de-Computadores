lw x10, a #armazenamento das variaveis
lw x11, b
lw x12, a
sw x12, m #inicializa m com o valor de a
blt x11, x12, soma #verifica se b < a
beq x0, x0, subtracao #else
soma:
    add x12, x10, x11 #soma a e b
    sw x12, m #guarda a variável
    halt #encerra o programa
subtracao:
    sub x12, x10, x11 #subtrai b de a (a - b)
    sw x12, m #guarda a variavel
    halt #encerra o programa

a: .word 25 #variaveis
b: .word 12
m: .word 0

#tabela de valores finais
#a: 6, 14, 25
#b: 15, 7, 12
#m: -9, 7, 37