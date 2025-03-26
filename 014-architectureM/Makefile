GRN=\033[0;32m
NC=\033[0m # No Color
MAKEFLAGS += --no-print-directory
all: prepare do_tests

SUBDIRS = div divu mul mulh mulhsu mulhu rem remu
.PHONY: subdirs $(SUBDIRS)

prepare:
	@mkdir obj_dir
	@cp -r ../plc8.mem obj_dir/
	@cp -r ../obj_dir/* obj_dir/
	@cp tb_soc.cc obj_dir/
	@cd obj_dir; make -f Vtesttop.mk Vtesttop -j$(nproc) > /dev/null; cd ..;

do_tests:	$(SUBDIRS)

$(SUBDIRS):
	@$(MAKE) -C $@ test
	@echo "${GRN}Passed test $@${NC}"

clean:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
	rm -rf obj_dir
 