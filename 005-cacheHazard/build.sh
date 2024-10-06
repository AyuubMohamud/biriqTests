rm -rf *.mem
rm -rf dump.txt
riscv32-unknown-elf-gcc -Iinclude -ffreestanding -nostdlib -mabi=ilp32 -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -Oz -c 005-cacheHazard.S -o 005-cacheHazard.o
riscv32-unknown-elf-gcc -T link.ld -o test005.elf -ffreestanding -nostdlib -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -Oz 005-cacheHazard.o
riscv32-unknown-elf-objdump -d test005.elf >> dump.txt
riscv32-unknown-elf-objcopy -O verilog --verilog-data-width=4 test005.elf test.mem
rm -rf *.o
rm -rf *.elf