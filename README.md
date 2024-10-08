# biriqTests

A series of tests aimed at providing bug testing for the Biriq CPU.

More tests upcoming

To run:
```Bash
git submodule init 
git submodule update
sh prepare.sh
make
make clean # For cleaning
```

Note that `make` will fail on the first failing test, and `trace.vcd` a trace dump of the failing test will be inside the folder of the test