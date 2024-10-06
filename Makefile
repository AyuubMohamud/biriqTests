all: do_tests

SUBDIRS = 000-testtests 001-ecall
.PHONY: subdirs $(SUBDIRS)

do_tests: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ test
 