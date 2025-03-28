.section ".text.boot"

.global _start
.global exception_handler

_start:
	lga x8, exception_handler
	csrrs x0, mstatus, 3
	csrrw x0, mtvec, x8
	call test

test:
	li x5, 0
	csrrw x0, minstret, x5
	csrrw x0, mcycle, x5
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
		li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
		li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
		li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
	li x5, 7
	add x5, x5, x5
	li x9, 55
	add x9, x5, x5
	li x10, 90
	li x11, 99
	add x11, x10, x11
    li x3, 0x80000000
	li x1, 50
    sw x1, 0(x3)
    sw x0, 16(x3)
1:  j 1b
exception_handler:
    li x3, 0x80000000
    sw x0, 0(x3)
    sw x0, 16(x3)
4:  j 4b