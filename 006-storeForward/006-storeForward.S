.global _start
_start:
    // this program checks for store forwarding errors
    la x2, array1
    addi x4, x0, 0xAA
    sb x4, 0(x2)
    mv x3, x4
    lbu x4, 0(x2)
    bne x4, x3, failure
    li x4, 0x0000AAAA
    sh x4, 4(x2)
    mv x3, x4
    lw x4, 4(x2)    
    bne x4, x3, failure
    li x3, 0x80000000
    li x2, 50
    sw x2, 0(x3)
    sw x0, 16(x3)
1:  j 1b
failure:
    li x3, 0x80000000
    sw x0, 0(x3)
    sw x0, 16(x3)
2:  j 2b
.section .data
.align 7
array1:
    .fill 128 , 1 , 0