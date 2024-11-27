.global _start
_start:
    c.li a0, 31
    c.xor a2, a1
    c.and a1, a1
    c.or a3, a2
    add x3, x1, x2
    c.and a0, a0
    add x2, x3, x4
    beq x0, x0, success
.align 7
success:
    li x3, 0x80000000
    li x2, 50
    sw x2, 0(x3)
    sw x0, 16(x3)
2:  j 2b

.section .data
.align 7
array1:
    .fill 128 , 1 , 0xEF