.global _start
_start:
    lga x2, exception_handler
    csrrw x0, mtvec, x2
    csrrc x0, mstatus, 12
    csrrc x0, mstatus, 11
    csrrs x0, mstatus, 21
    lga x2, user_mode_program
    csrrw x0, mepc, x2
    mret

user_mode_program:
    wfi
9:  j 9b

exception_handler:
    csrrw x2, mcause, x0
    li x3, 2
    beq x2, x3, success
1:  j 1b
success:  li x2, 50
    li x3, 0x80000000
    sw x2, 0(x3)
    sw x0, 16(x3)
3:  j 3b