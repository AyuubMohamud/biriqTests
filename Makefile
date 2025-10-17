MAKEFLAGS += --no-print-directory
all: prepare do_tests

SUBDIRS = 000-testtests 001-ecall 002-ecallFromUser 003-unalignedLoad 004-unalignedStore 005-cacheHazard 006-storeForward 007-selfModifyingCode 008-testZeroReg 009-recursiveFunctionCalls 010-testTW 011-testCBOZ 012-testArray 013-testArrayDiv 014-architectureIMZba_Zbb_Zbs 015-primes 016-embench 100-PMPTest 101-PMPTest2 102-PMPTest3
.PHONY: subdirs $(SUBDIRS)

prepare:
	-/opt/oss-cad-suite/bin/verilator -O3 --x-assign fast --x-initial fast --noassert --trace -threads 4 -cc -IBiriq/rtl/ooo -IBiriq/rtl/meu -IBiriq/rtl/ifu -IBiriq/rtl/ixu -IBiriq/rtl/ixu/alu -IBiriq/rtl -ITileLinkIP/rtl/sram -ITileLinkIP/rtl/interconnect -ITileLinkIP/rtl/common -Idebug testtop.sv --exe tb_soc.cc

do_tests:	$(SUBDIRS)

$(SUBDIRS):
	@$(MAKE) -C $@ test

lint:
	/opt/oss-cad-suite/bin/verilator --lint-only -Wall -IBiriq/rtl/ooo -IBiriq/rtl/meu -IBiriq/rtl/ifu -IBiriq/rtl/ixu -IBiriq/rtl/ixu/alu -IBiriq/rtl -ITileLinkIP/rtl/sram -ITileLinkIP/rtl/interconnect -Idebug testtop.sv --exe tb_soc.cc
clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
	for dir in $(SUBDIRS_PMP); do \
		$(MAKE) -C $$dir clean; \
	done
	rm -rf obj_dir
 