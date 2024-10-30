rm -rf *.mem
rm -rf dump.txt
riscv32-unknown-elf-gcc -Iinclude -ffreestanding -nostdlib -mabi=ilp32 -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei_zicboz -Oz -c 011-testCBOZ.S -o 011-testCBOZ.o
riscv32-unknown-elf-gcc -T link.ld -o ecall000.elf -ffreestanding -nostdlib -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei_zicboz -Oz 011-testCBOZ.o
riscv32-unknown-elf-objdump -d ecall000.elf >> dump.txt
riscv32-unknown-elf-objcopy -O verilog --verilog-data-width=4 ecall000.elf test.mem
rm -rf *.o
rm -rf *.elf