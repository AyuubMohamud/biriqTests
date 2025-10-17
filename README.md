# biriqTests

## Overview
This repo contains a series of tests aimed at providing bug testing for the Biriq CPU.

To run:
```Bash
git submodule init 
git submodule update
make
make clean # For cleaning
```

Note that `make` will fail on the first failing test, and `trace.vcd` a trace dump of the failing test will be inside the folder of the test

plc8.mem used to be used for the population count instruction on the CPU, but now it isn't, it's just there because the makefiles all copy it over anyways :\(

testtop.sv is the fake SOC top file used to test the CPU.

To run these tests you will need the `riscv32-unknown-elf-gcc`, `riscv32-unknown-elf-objdump` and `riscv32-unknown-elf-objcopy` on your computer.

## Test descriptions
### 000-testtests
Tests whether the testing framework works, and tests basic instruction execution.
### 001-ecall
Tests `ecall` instruction from machine mode.
### 002-ecallFromUser
Tests `ecall` instructions from user mode.
### 003-unalignedLoad
Tests whether unaligned loads trap.
### 004-unalignedStore
Tests whether unaligned storess trap.
### 005-cacheHazard
Tests whether the CPU stalls when receving a miss while refilling a cache line
### 006-storeForward
Tests whether store forwarding works correctly
### 007-selfModifyingCode
Tests whether the CPU's frontend can resteer correctly and invalidate wrong BTB entries.
### 008-testZeroReg
Tests if the `x0` register works
### 009-recursiveFunctionCalls
Tests if recursive function calls work.
### 010-testTW
Tests if `tw` trapping works.
### 011-testCBOZ
Tests the `cbo.zero` instruction.
### 012-testArray
Tests the CPU by summing up an array and checking the result.
### 013-testArrayDiv
Tests the CPU by summing up an array while dividing it by 2 and checking the result.
### 014-architectureIMZba_Zbb_zbs
Tests the CPU using the RISC-V compliance tests from: https://github.com/riscv-software-src/riscv-tests/tree/master/isa
### 015-primes
Tests the CPU using a modified version of: https://hoult.org/primes.txt
### 016-embench
Tests the CPU using some tests from Embench-IoT, using code from newlib and musl to provide certain C stdlib functions.
### 100-PMPTest, 101-PMPTest2, 102-PMPTest3
All of these test the NAPOT protection mode inside the MPU.

