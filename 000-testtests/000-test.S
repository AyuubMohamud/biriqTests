.global _start
_start:
	li x10, 0x80000000
    li x2, 0xFFF00020
	li x3, 0x00020002
	psx.dot2d x2, x2, x3 // correct result is 32 
    sw x2, 0(x10)
    sw x0, 16(x10)
1: 	j 1b