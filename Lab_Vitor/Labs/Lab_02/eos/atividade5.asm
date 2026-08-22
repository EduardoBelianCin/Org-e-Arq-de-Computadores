addi x12, x0, 42     # Caractére "*" em ASCII.     
LOOP:
lb x10, 1025(x0)     # lê 1 byte do input do teclado.
beq x10, x12, FIM    # se for '*', vai pro fim.
sb x10, 1024(x0)     # escreve no vídeo.
jal x0, LOOP         # volta ao início do loop, como não há volta, não precisa guardar num registrador(logo guarda no x0).
# =======================================
FIM:
halt