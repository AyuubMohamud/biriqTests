.global _start
_start:
    li ra, 0x80000000
    li t0, 0x9ABC1024
    li t2, 9
    sh1add t1, t0, t2
    sw t1, 0(ra)
    sh2add t1, t0, t2
    sw t1, 4(ra)
    sh3add t1, t0, t2
    sw t1, 8(ra)
    sw x0, 16(ra)
1:  j 1b