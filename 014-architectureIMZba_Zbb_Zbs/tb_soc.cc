#include "/opt/oss-cad-suite/share/verilator/include/verilated_vcd_c.h"
#include "Vtesttop.h"
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <iostream>
vluint64_t simtime = 0;

int main() {
  Vtesttop *soc = new Vtesttop;
  Verilated::traceEverOn(true);
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  soc->trace(m_trace, 15);
  m_trace->open("trace.vcd");
  soc->eval();
  bool failedOut = true;
  for (vluint64_t i = 0; i < 10000000; i++) {
    if (soc->callenv) {
      failedOut = false;
      break;
    } else {
      soc->clk = 1;
      soc->eval();
      m_trace->dump(simtime);
      simtime++;
      soc->clk = 0;
      soc->eval();
      m_trace->dump(simtime);
      simtime++;
    }
  }
  if (soc->state_o.at(0) == 1 && !failedOut) {
    printf("PASS\n");
  } else if (failedOut) {
    printf("TIMEOUT\n");
  } else {
    printf("FAIL %d\n", soc->state_o.at(0));
  }
  m_trace->close();
  delete soc;
}