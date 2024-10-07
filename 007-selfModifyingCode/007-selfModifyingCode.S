.global _start
_start:
    nop
    nop
    nop
    nop
    nop
    addi x3, x0, 19
    call someRandomFunc
    auipc x1, 0
    sw x3, -4(x1) // modify the call instruction into a nop
    j _start // go back to beginning, now the jump is registered in the BTB

someRandomFunc:
    la x10, array1
    lw x11, 0(x10)
    bnez x11, failure
    addi x11, x0, 128
    sw x11, 0(x10)
    ret

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