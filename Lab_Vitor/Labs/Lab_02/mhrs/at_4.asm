lw x28, point1 # Init reg pro ponteiro

loop1:
    lb x10, 0(x28) # Load byte no char atual da string
    beq x10, x0, end1 # case pra acabar o while loop
    sb x10, 1024(x0) # Save byte na memória do vídeo do CompSim
    addi x28, x28, 1 # Avança o ponteiro em 1 char
    jal x1, loop1 # volta pro começo do loop
end1:
halt

point1: .word str1 # Pointeiro pra string
str1: .string "Hello World"