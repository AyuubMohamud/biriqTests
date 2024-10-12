.global _start
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
    csrrw x0, pmpaddr0, x2
    addi x3, x0, 24
    //bseti x3, x3, 0
    csrrw x0, pmpcfg0, x3
    mret
.align 7
user_mode_program:
    wfi
9:  j 9b
.align 7
exception_handler:
    csrrw x2, mcause, x0
    li x3, 1
    beq x2, x3, success
1:  j 1b
success:  li x2, 50
    li x3, 0x80000000
    sw x2, 0(x3)
    sw x0, 16(x3)
3:  j 3b