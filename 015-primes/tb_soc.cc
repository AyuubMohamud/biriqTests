#include "/opt/oss-cad-suite/share/verilator/include/verilated_vcd_c.h"
#include "Vtesttop.h"
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <stdint.h>
#include <stdio.h>
#include <time.h>

vluint64_t simtime = 0;

int main() {
  std::cerr << "Starting simulation" << std::endl;
  Vtesttop *soc = new Vtesttop;
  Verilated::traceEverOn(true);
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  soc->trace(m_trace, 15);
  m_trace->open("trace.vcd");
  soc->eval();
  bool failedOut = true;
  bool startTrace = false;
  clock_t start = clock();
  soc->clk = 1;
  soc->eval();
  soc->clk = 0;
  soc->eval();
  start = clock();
  soc->clk = 1;
  soc->eval();
  soc->clk = 0;
  soc->eval();
  start = clock();
  soc->clk = 1;
  soc->eval();
  soc->clk = 0;
  soc->eval();
  double kHz =
      (1 / ((double)(clock() - start) / (double)(CLOCKS_PER_SEC))) / 1000;
  std::cerr << "Running verilator model at " << kHz << " kHz" << std::endl;
  for (vluint64_t i = 0; i < 10000000; i++) {
    if (soc->callenv) {
      if (soc->state_o.at(0) == 1) {
        std::cerr << "Starting trace" << std::endl;
        //startTrace = true;
      } else {
        failedOut = false;
        goto finish;
      }
    }
    soc->clk = 1;
    soc->eval();
    if (startTrace) {
      m_trace->dump(simtime);
    }
    simtime++;
    soc->clk = 0;
    soc->eval();    
    if (startTrace) {
      m_trace->dump(simtime);
    }
    simtime++;
  }
finish:
  m_trace->close();
  if (soc->state_o.at(0) == 0x00000032 && !failedOut) {
    printf("PASSED TEST: Test primes\n");
  } else if (failedOut) {
    printf("Failed out\n");
  } else {
    printf("FAIL: Value was 0x%04X\n", soc->state_o.at(0));
    return -1;
  }

  delete soc;
}