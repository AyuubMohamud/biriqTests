.global _start
_start:
    li t0, 14
    li t1, -1
    li t2, -80
    li t3, 99
    li t4, 87
    li t5, 255
    li t6, 1024

    mv zero, t6
    mv t6, zero

    mv zero, t5
    mv t5, zero

    mv zero, t4
    mv t4, zero

    mv zero, t3
    mv t3, zero

    mv zero, t2
    mv t2, zero

    mv zero, t1
    mv t1, zero

    mv zero, t0
    mv t0, zero

    li s0, 0
    bne s0, zero, failure
    bne s0, t0, failure
    bne s0, t1, failure
    bne s0, t2, failure
    bne s0, t4, failure
    bne s0, t5, failure
    bne s0, t6, failure
    li s0, 0x80000000
    li sp, 50
    sw sp, 0(s0)
    sw zero, 16(s0)
1:  j 1b

failure:
    li s1, 0x80000000
    sw s0, 0(s1)
    sw zero, 16(s1)
2:  j 2b
