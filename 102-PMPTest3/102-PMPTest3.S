.global _start
.section .text
_start:
    lga x2, exception_handler
    csrrw x0, mtvec, x2
    csrrc x0, mstatus, 12
    csrrc x0, mstatus, 11
    lga x2, user_mode_program
    csrrw x0, mepc, x2
    srli x2, x2, 2
    addi x3, x0, 0x1f
    andn x2, x2, x3
    ori  x2, x2, 0x0f
    csrrw x0, pmpaddr1, x2
    addi x3, x0, 28
    csrrw x0, pmpcfg1, x3

    la x2, array1
    srli x2, x2, 2
    addi x3, x0, 0x1f
    andn x2, x2, x3
    ori  x2, x2, 0x0f
    csrrw x0, pmpaddr0, x2
    addi x3, x0, 25
    csrrw x0, pmpcfg0, x3
    mret
.align 7
user_mode_program:
    la x1, array1
    lw x0, 0(x1)
    sw x0, 0(x1)
9:  j 9b
.align 7
exception_handler:
    csrrw x2, mcause, x0
    li x3, 7
    beq x2, x3, success
1:  j 1b
success:  li x2, 50
    li x3, 0x80000000
    sw x2, 0(x3)
    sw x0, 16(x3)
3:  j 3b

.section .data
.align 7
array1:
    .fill 128 , 1 , 0