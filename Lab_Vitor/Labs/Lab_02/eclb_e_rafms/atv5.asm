addi x30, x0, 42 # Valor em decimal do char '*'

loop:
    lb x10, 1025(x0)  # le um caractere do teclado
    beq x10, x0, FIM  # END - fim da frase
	beq x10, x30, FIM # END - char == '*'
    sb x10, 1024(x0)  # envia o byte para 1024(x0) saída
    jal x1, loop      # faz o loop novamente
FIM:

halt # encerra o programa