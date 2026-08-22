# -- loads --
lw x10, ptr      # Ponteiro para a string.
# =======================================
LOOP:
lb x11, 0(x10)   # Byte que o ponteiro aponta.
beq x11, x0, FIM # Acabou a frase.
sb x11, 1024(x0) # Imprimir no vídeo.
addi x10, x10, 1 # Avança o ponteiro.
beq x0, x0, LOOP # Volta ao loop.

FIM:
halt
# =======================================
ptr: .word str
str: .string "Hello World"