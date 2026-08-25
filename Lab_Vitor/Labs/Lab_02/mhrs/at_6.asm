# Assumi que o objetivo era fazer a luz avançar após cada pressionada, ficou ambiguo no slide

start:
	lw x29, HIGH # coloca o 1 no reg 29	
	sb x29, 1029(x0) # liga o primeiro led como pedido
	addi x28, x0, 64 # estabelece o limite, já que são 8-13 portas, são 6 portas únicas 2⁶=64
loop:
	lb x10, 1026(x0) # Da load byte no input na porta 8
	beq x10, x0, loop # Se for 0 volta pro começo do loop
on: 
	slli x29, x29, 1 # Dobra o valor do 29 pra avançar pra próxima porta, de 2-7
	sb x29, 1029(x0) # Salva isso na memória para ligar o próximo led
	beq x29, x28, off # Acaba o código se chegar no limite
	jal x1, loop # Volta pro loop de input
off:
    addi x29, x0, 1 # Previne o overflow
    lb x10, 1026(x0) # Previne o overflow na próxima execução
    beq x10, x29, off # Previne o overflow na próxima execução ao voltar o código até receber 0 no botão
    halt

HIGH: .byte 1
LOW:  .byte 0