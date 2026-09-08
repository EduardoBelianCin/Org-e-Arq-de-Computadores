addi x10, x0, 1 #inicializa x10 com o valor 1(00000001) para acender o primeiro led
sb x10, 1029(x0) # acende o primeiro LED
addi x11, x0, 64 #define o valor limite 64 em x11(1000000) para não exibir do oitavo led em diante

loop:
	lb x12, 1026(x0) #chama o input
	beq x12, x0, loop #aguarda o input ser 1

passa: 
	slli x10, x10, 1 #desloca o bit 1 posição para a esquerda (multiplica x10 por 2)
	sb x10, 1029(x0) #envia o valor de x10 para a saída
	beq x10, x11, fim #verifica se x10 < 64
	jal x0, loop #retorna para aguardar a próxima ordem

fim:
	sb x0, 1029(x0) #envia 0 para a saída no endereço 1029 (desliga os LEDs)
    halt #encerra o programa
