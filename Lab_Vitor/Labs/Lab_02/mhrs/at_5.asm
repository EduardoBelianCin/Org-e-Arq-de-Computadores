addi x28, x0, 42 # Valor em decimal do char '*'

loop1:
    lb x10, 1025(x0) # Load byte no char atual do tecladp
    beq x10, x0, end1 # case pra acabar o while loop quando a frase acaba
	beq x10, x28, end1 # case pra acabar quando o char for '*'
    sb x10, 1024(x0) # Save byte na memória do vídeo do CompSim
    jal x1, loop1 # volta pro começo do loop
end1:
halt