.global _start
_start:
    call add
    call add
    call add
    call add
    call add
    j _start

add:
    add a0, a0, a1
    ret
.section .data
.align 7
array1:
    .fill 128 , 1 , 0xEF