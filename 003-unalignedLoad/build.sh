rm -rf *.mem
rm -rf dump.txt
riscv32-unknown-elf-gcc -Iinclude -ffreestanding -nostdlib -mabi=ilp32 -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -Oz -c 003-unalignedLoad.S -o 003-unalignedLoad.o
riscv32-unknown-elf-gcc -T link.ld -o unalignedLoad003.elf -ffreestanding -nostdlib -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -Oz 003-unalignedLoad.o
riscv32-unknown-elf-objdump -d unalignedLoad003.elf >> dump.txt
riscv32-unknown-elf-objcopy -O verilog --verilog-data-width=4 unalignedLoad003.elf test.mem
rm -rf *.o
rm -rf *.elf