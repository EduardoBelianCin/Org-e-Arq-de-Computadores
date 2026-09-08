lw x30, ptr # carrega o endereço de STR

loop:
    lb x10, 0(x30)   # le um byte da memória
    beq x10, x0, FIM # verifica se o byte é 0x0
    sb x10, 1024(x0) # envia o byte para 1024(x0) saída
    addi x30, x30, 1 # avança o ponteiro para o próximo caractere
    jal x1, loop     # faz o loop novamente
FIM:

halt # encerra o programa

# VARIAVEIS
ptr: .word str       # ponteiro pra string
str: .string "Hello World"