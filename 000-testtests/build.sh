rm -rf *.mem
rm -rf dump.txt
riscv32-unknown-elf-gcc -Iinclude -ffreestanding -nostdlib -mabi=ilp32 -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -Oz -c 000-test.S -o 000-test.o
riscv32-unknown-elf-gcc -T link.ld -o test000.elf -ffreestanding -nostdlib -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -Oz 000-test.o
riscv32-unknown-elf-objdump -d test000.elf >> dump.txt
riscv32-unknown-elf-objcopy -O verilog --verilog-data-width=4 test000.elf test.mem
rm -rf *.o
rm -rf *.elf