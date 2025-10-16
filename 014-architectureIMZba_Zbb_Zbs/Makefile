GRN=\033[0;32m
NC=\033[0m # No Color
FILES_A := $(wildcard tests/*)

MAKEFLAGS += --no-print-directory --no-builtin-rules
test : all
all: prepare do_tests

FILES_B := $(FILES_A:.S=)
FILES = $(notdir $(FILES_B))
.PHONY: files $(FILES)

prepare:
	@echo "Running RISC-V compliance tests"
	@mkdir obj_dir
	@cp -r ../plc8.mem obj_dir/
	@cp -r ../obj_dir/* obj_dir/
	@cp tb_soc.cc obj_dir/
	@cd obj_dir; make OPT_FAST="-O3 -march=native -fstrict-aliasing" -f Vtesttop.mk Vtesttop -j$(nproc) > /dev/null; cd ..;

do_tests:	$(FILES)

$(FILES):
	@mkdir $@
	@cp tests/$@.S $@/test.S
	@cp Makefile.test $@/
	@mv $@/Makefile.test $@/Makefile
	@$(MAKE) -C $@ test
	@echo "${GRN}Passed test $@${NC}"

clean:
	for dir in $(FILES); do \
		rm -rf $$dir; \
	done
	rm -rf obj_dir
 