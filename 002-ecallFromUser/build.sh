rm -rf *.mem
rm -rf dump.txt
riscv32-unknown-elf-gcc -Iinclude -ffreestanding -nostdlib -mabi=ilp32 -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -Oz -c 002-ecallFromUser.S -o 002-ecall.o
riscv32-unknown-elf-gcc -T link.ld -o ecall002.elf -ffreestanding -nostdlib -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -Oz 002-ecall.o
riscv32-unknown-elf-objdump -d ecall002.elf >> dump.txt
riscv32-unknown-elf-objcopy -O verilog --verilog-data-width=4 ecall002.elf test.mem
rm -rf *.o
rm -rf *.elf