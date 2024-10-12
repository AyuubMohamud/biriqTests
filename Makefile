all: do_tests

SUBDIRS = 000-testtests 001-ecall 002-ecallFromUser 003-unalignedLoad 004-unalignedStore 005-cacheHazard 006-storeForward 007-selfModifyingCode 008-testZeroReg 009-recursiveFunctionCalls 010-testTW
SUBDIRS_PMP = 100-PMPTest
.PHONY: subdirs $(SUBDIRS)
.PHONY: subdirs_pmp $(SUBDIRS_PMP)
do_tests:	$(SUBDIRS)
do_pmp:		$(SUBDIRS_PMP)

$(SUBDIRS):
	@$(MAKE) -C $@ test

$(SUBDIRS_PMP):
	@$(MAKE) -C $@ test

clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
	for dir in $(SUBDIRS_PMP); do \
		$(MAKE) -C $$dir clean; \
	done
	rm -rf obj_dir
 