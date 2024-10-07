.global _start
_start:
    li ra, 0x80000000
    li s0, -1
    li s1, 64
    li s2, 0xA0A0A0A0
    li s3, 0x00000077
    li s4, 0xABCEAF0D
    li s5, 0x981ABEFA
    li s6, 0xDEADBEEF
    li s7, 32
    call testandn

envcall:
    sw t0, 0(ra)
    sw zero, 16(ra)
    ret

testandn:
    andn t0, s0, zero // -1 & !0, so should be 0xFFFFFFFF
    jal x1, envcall

    andn t0, s0, s7 // bottom 5 bits should be zero so 0xFFFFFFE0
    jal x1, envcall

    andn t0, s0, s3 // should be 0xFFFFFF11
    jal x1, envcall

    andn t0, s7, zero // Should be 32
    jal x1, envcall

    ret

testorn:
    orn t0, s0, zero // -1 & !0, so should be 0xFFFFFFFF
    jal x1, envcall

    orn t0, s7, s1 // Should be 32 | !64 so 0xFFFFFFBF
    jal x1, envcall

    orn t0, s7, zero // Should be 0xFFFFFFFF
    jal x1, envcall

    ret

testxnor:
    xnor t0, zero, zero
    jal x1, envcall