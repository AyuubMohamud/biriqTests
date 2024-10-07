.global _start
_start:
    mv x31, x0
    li x3, 19
    nop
    nop
    nop
    nop
    li x30, 3
1:  addi x31, x31, 1
    beq x30, x31, evaluate 
    la x10, array1
    lw x11, 0(x10)
    call someRandomFunc
    auipc x1, 0
    sw x3, -4(x1) // modify the call instruction into a nop
    fence.i
    j 1b

someRandomFunc:
    la x10, array1
    lw x11, 0(x10)
    addi x11, x11, 1
    sw x11, 0(x10)
    ret

evaluate:
    li x31, 1
    la x10, array1
    lw x11, 0(x10)
    beq x31, x11, success
    j failure

success:
    li x3, 0x80000000
    li x2, 50
    sw x2, 0(x3)
    sw x0, 16(x3)
1:  j 1b

failure:
    li x3, 0x80000000
    sw x0, 0(x3)
    sw x0, 16(x3)
1:  j 1b
.section .data
.align 7
array1:
    .fill 128 , 1 , 0