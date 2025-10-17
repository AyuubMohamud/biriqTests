.global _start
_start:
    lga x2, exception_handler
    csrrw x0, mtvec, x2
    li x2, 0x0F0F0F0F
    sh x0, 0(x2) // should take exception

    li x3, 0x80000000
    sw x0, 0(x3)
    sw x0, 16(x3)    

    li x2, 0x0F0F0F0F
    sw x0, 0(x2) // should take exception

    li x3, 0x80000000
    sw x0, 0(x3)
    sw x0, 16(x3)

    li x3, 0x80000000
    li x2, 50
    sw x2, 0(x3)
    sw x0, 16(x3)
1:  j 1b
exception_handler:
    csrrw x10, mcause, x0
    csrrw x11, mepc, x0
    add x11, x11, 16
    csrrw x0, mepc, x11
    mret
