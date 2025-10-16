rm -rf *.mem
rm -rf dump.txt
riscv32-unknown-elf-gcc -Iinclude -ffreestanding -nostdlib -mabi=ilp32e -march=rv32em_zba_zbb_zbs_zicond_zicsr_zifencei -Og -c 000-test.S -o 000-test.o > /dev/null
riscv32-unknown-elf-gcc -T link.ld -o test000.elf -ffreestanding -nostdlib -march=rv32em_zba_zbb_zbs_zicond_zicsr_zifencei -Og 000-test.o > /dev/null
riscv32-unknown-elf-objdump -d test000.elf >> dump.txt
riscv32-unknown-elf-objcopy -O verilog --verilog-data-width=4 test000.elf test.mem
rm -rf *.o
rm -rf *.elf