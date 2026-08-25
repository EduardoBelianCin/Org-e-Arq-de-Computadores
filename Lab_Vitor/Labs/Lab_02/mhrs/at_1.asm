lw x10, a
lw x11, b
add x12, x10, x0
sw x10, m

blt x11, x12, less
beq x0, x0, end1
less: 
	add x12, x10, x11
	sw x12, m
end1:
halt 

a: .word 6 # valores em decimal
b: .word 15
m: .word 0