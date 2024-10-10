test: 002-test
.PHONY: 002-test
002-test:
	@echo "Building Test 3: Test unaligned load"
	@sh ./build.sh
	@mkdir obj_dir
	@cp -r ../plc8.mem obj_dir/
	@cp -r test.mem obj_dir/
	@cp -r ../obj_dir/* obj_dir/
	@cp tb_soc.cc obj_dir/
	@cd obj_dir; make -f Vtesttop.mk Vtesttop -j$(nproc) > /dev/null; ./Vtesttop > ../result.txt; cp trace.vcd ../;
	@diff result.txt expected.txt
.PHONY: clean
clean:
	@rm -rf obj_dir
	@rm -rf result.txt
	@rm -rf trace.vcd
	@rm -rf test.mem
	@rm -rf dump.txt