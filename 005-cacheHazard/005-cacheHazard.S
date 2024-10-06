.global _start
_start:
    // this program checks for a cache miss succeeding under an existing cache miss to a diiferent line, something that wk_failed_enqueue catches
    la x2, array1
    la x3, array2
    addi x4, x0, 0xAA
    lbu x2, 0(x2)
    lbu x3, 0(x3)
    beq x4, x3, part2
    li x3, 0x80000000
    sw x0, 0(x3)
    sw x0, 16(x3)
1:  j 1b
part2:
    beqz x2, success
    li x3, 0x80000000
    sw x0, 0(x3)
    sw x0, 16(x3)
3:  j 3b
success:
    li x3, 0x80000000
    li x2, 50
    sw x2, 0(x3)
    sw x0, 16(x3)
2:  j 2b
.section .data
.align 7
array1:
    .fill 128 , 1 , 0
array2:
    .fill 128, 1, 0xAA