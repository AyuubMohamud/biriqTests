rm -rf *.mem
rm -rf dump.txt
riscv32-unknown-elf-gcc -Iinclude -ffreestanding -nostdlib -mabi=ilp32 -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -Oz -c 004-unalignedStore.S -o 004-unalignedStore.o
riscv32-unknown-elf-gcc -T link.ld -o unalignedStore004.elf -ffreestanding -nostdlib -march=rv32im_zba_zbb_zbs_zicond_zicsr_zifencei -Oz 004-unalignedStore.o
riscv32-unknown-elf-objdump -d unalignedStore004.elf >> dump.txt
riscv32-unknown-elf-objcopy -O verilog --verilog-data-width=4 unalignedStore004.elf test.mem
rm -rf *.o
rm -rf *.elf