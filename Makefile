all: do_tests

SUBDIRS = 000-testtests 001-ecall 002-ecallFromUser 003-unalignedLoad 004-unalignedStore 005-cacheHazard 006-storeForward 007-selfModifyingCode
.PHONY: subdirs $(SUBDIRS)

clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done

do_tests: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ test
 