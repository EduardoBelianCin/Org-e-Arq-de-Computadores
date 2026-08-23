addi x11, x0, 0x2A #carrega o caractere '*' (código ASCII 0x2A em hexadecimal) em x11

loop:
    lb x10, 1025(x0) #lê um caractere do dispositivo de entrada
    sb x10, 1024(x0) #envia o caractere lido para a saída
    beq x10, x11, fim #verifica se o caractere lido é '*'
    jal x0, loop #desvia incondicionalmente de volta para o início do loop
fim:
    halt #encerra o programa