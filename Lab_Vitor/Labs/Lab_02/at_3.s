# Pseudo código(.C)
# if(i==j){
#	f = g+h;
#}else{
#	f = g-h;	
#}
# Código assembly abaixo:

lw x19, f
lw x20, g
lw x21, h
lw x22, i
lw x23, j

beq x22, x23, isequal
beq x0, x0, else1

isequal:
    add x19, x20, x21
    sw x19, f
    beq x0, x0, end1
else1:
    sub x19, x20, x21
    sw x19, f
end1:
halt

f: .word 1 # valores em decimal
g: .word 2
h: .word 3
i: .word 4
j: .word 5


