lw x10, str #carrega o endereço base de str no registrador x10
Loop:
    lb x11, 0(x10) #le um byte da memória
    beq x11, x0, FIM #verifica se o byte é 0x0
    sb x11, 1024(x0) #envia o byte para 1024(x0) saída
    addi x10, x10, 1 #avança o ponteiro para o próximo caractere
    beq x0, x0, Loop #desvia para o início do Loop
FIM:
    halt #encerra o programa

str: .string "Hello World" #variavel do tipo string