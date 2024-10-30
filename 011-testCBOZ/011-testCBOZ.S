.global _start
_start:
    // this program checks for store forwarding errors
    la x2, array1
    lw x0, 4(x2) // load data so it gets cached
    cbo.zero 0(x2)
    lw x1, 4(x2)
    beq x0, x1, success
1:  j 1b
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