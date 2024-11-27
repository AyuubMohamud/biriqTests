rm -rf *.mem
rm -rf dump.txt
riscv32-unknown-elf-gcc -Iinclude -ffreestanding -nostdlib -mabi=ilp32 -march=rv32imc_zcb_zba_zbb_zbs_zicond_zicsr_zifencei -Oz -c start.S -o start.o
riscv32-unknown-elf-gcc -Iinclude -ffreestanding -nostdlib -mabi=ilp32 -march=rv32imc_zcb_zba_zbb_zbs_zicond_zicsr_zifencei -Oz -c main.c -o main.o
riscv32-unknown-elf-gcc -T link.ld -o test014.elf -ffreestanding -nostdlib -march=rv32imc_zcb_zba_zbb_zbs_zicond_zicsr_zifencei -Oz main.o start.o
riscv32-unknown-elf-objdump -d test014.elf >> dump.txt
riscv32-unknown-elf-objcopy -O verilog --verilog-data-width=4 test014.elf test.mem
rm -rf *.o
rm -rf *.elf