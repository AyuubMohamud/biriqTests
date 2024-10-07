rm -rf *.mem
rm -rf dump.txt
riscv32-unknown-elf-gcc -Iinclude -ffreestanding -nostdlib -mabi=ilp32 -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -Oz -c 007-selfModifyingCode.S.S -o 007-selfModifyingCode.S.o
riscv32-unknown-elf-gcc -T link.ld -o test006.elf -ffreestanding -nostdlib -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -Oz 007-selfModifyingCode.S.o
riscv32-unknown-elf-objdump -d test007.elf >> dump.txt
riscv32-unknown-elf-objcopy -O verilog --verilog-data-width=4 test007.elf test.mem
rm -rf *.o
rm -rf *.elf