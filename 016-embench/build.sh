rm -rf *.mem
rm -rf dump.txt
riscv32-unknown-elf-gcc -mabi=ilp32e -march=rv32em_zba_zbb_zbs_zicsr_zifencei -O2 -mcmodel=medany -falign-functions=8 -falign-loops=8 -ffreestanding -I. -T link.ld -nostdlib -static-libgcc *.c start.S -o test.elf
riscv32-unknown-elf-objdump -d test.elf >> dump.txt
riscv32-unknown-elf-objcopy -O verilog --verilog-data-width=4 test.elf test.mem
rm -rf *.o
rm -rf *.elf