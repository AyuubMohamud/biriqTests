all: do_tests

SUBDIRS = 000-testtests 001-ecall 002-ecallFromUser 003-unalignedLoad 004-unalignedStore 005-cacheHazard 006-storeForward 007-selfModifyingCode 008-testZeroReg 009-recursiveFunctionCalls
.PHONY: subdirs $(SUBDIRS)

do_tests: $(SUBDIRS)

$(SUBDIRS):
	@$(MAKE) -C $@ test

clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done

 