addi x10, x0, 1 #inicializa x10 com o valor 1(00000001) para acender o primeiro led
addi x11, x0, 64 #define o valor limite 64 em x11(1000000) para não exibir do oitavo led em diante
loop:
    sb x10, 1029(x0) #envia o valor de x10 para a saída
    slli x10, x10, 1 #desloca o bit 1 posição para a esquerda (multiplica x10 por 2)
    blt x10, x11, loop #verifica se x10 < 64
off:
    sb x0, 1029(x0) #envia 0 para a saída no endereço 1029 (desliga os LEDs)
    halt #encerra o programa