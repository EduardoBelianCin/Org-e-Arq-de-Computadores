# if i==j
#     then f = g + h
# else f = g - h
# end

lw x19, f #armazenamento das variáveis
lw x20, g
lw x21, h
lw x22, i
lw x23, j

beq x22, x23, soma #verifica se i = j
beq x0, x0, subtracao #else
soma:
    add x19, x20, x21 #soma g e h
    sw x19, f #guarda o resultado na variável
    halt #encerra o programa
subtracao:
    sub x19, x20, x21 #subtrai h de g
    sw x19, f #guarda o resultado
    halt #encerra o programa

f: .word 0x0 # variaveis
g: .word 0x0
h: .word 0x0
i: .word 0x0
j: .word 0x0