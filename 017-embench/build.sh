rm -rf *.mem
rm -rf dump.txt
riscv32-unknown-elf-gcc -mabi=ilp32 -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -O2 -falign-functions=8 -falign-loops=8 -ffreestanding -I. -T link.ld -nostdlib -static-libgcc *.c start.S -o test.elf
riscv32-unknown-elf-objdump -d test.elf >> dump.txt
riscv32-unknown-elf-objcopy -O verilog --verilog-data-width=4 test.elf test.mem
rm -rf *.o
rm -rf *.elf