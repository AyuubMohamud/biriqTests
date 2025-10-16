.global _start
_start:
	li x10, 0x80000000
    li x2, 90
	li x3, 2
	div x2, x2, x3 // correct result is 45
    add x0, x0, x1
    addi x1, x2, 3
    sw x2, 0(x10)
    sw x0, 16(x10)
1: 	j 1b