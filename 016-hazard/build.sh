rm -rf *.mem
rm -rf dump.txt
riscv32-unknown-elf-gcc -Iinclude -ffreestanding -nostdlib -mabi=ilp32 -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -Oz -c start.S -o start.o
riscv32-unknown-elf-gcc -T link.ld -o test009.elf -ffreestanding -nostdlib -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -Oz start.o
riscv32-unknown-elf-objdump -d test009.elf >> dump.txt
riscv32-unknown-elf-objcopy -O verilog --verilog-data-width=4 test009.elf test.mem
rm -rf *.o
rm -rf *.elf