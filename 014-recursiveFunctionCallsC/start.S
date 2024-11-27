.section ".text.boot"

.global _start
.global exception_handler

_start:
	lga x8, exception_handler
	csrrs x0, mstatus, 3
	csrrw x0, mtvec, x8
	lga x2, _start
	lga x3, __bss_start
	lga x4, __bss_size
	li x5, 1
1:	beqz x4, 2f
	sb x0, 0(x3)
	addi x3, x3, 1
	sub x4, x4, x5
	bnez x4, 1b
2:	call main
3: 	j 3b

exception_handler:
    li x3, 0x80000000
    sw x0, 0(x3)
    sw x0, 16(x3)
4:  j 4b