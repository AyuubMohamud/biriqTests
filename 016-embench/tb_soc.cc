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
  bool timeout = false;
  bool trace = false;
  vluint64_t counter_start = 0, counter_end = 0;

  clock_t start, end;
  double kHz;
  soc->clk = 1;
  soc->eval();
  soc->clk = 0;
  soc->eval();
  soc->clk = 1;
  soc->eval();
  soc->clk = 0;
  soc->eval();
  for (vluint64_t k = 0; k < 50; k++) {
    start = clock();
    soc->clk = 1;
    soc->eval();
    soc->clk = 0;
    soc->eval();
    end = clock();
    kHz +=
        (1.0 / ((double)(clock() - start) / (double)(CLOCKS_PER_SEC))) / 1000.0;
  }
  kHz /= 50.0;
  std::cerr << "Running verilator model at " << kHz << " kHz" << std::endl;
  for (vluint64_t i = 0; i < 100000000; i++) {
    if (soc->callenv) {
      if (soc->state_o.at(0) == 1) {
        std::cerr << "Starting timer" << std::endl;
        counter_start = i;
      } else if (soc->state_o.at(0) == 2) {
        failedOut = false;
        counter_end = i;
        goto finish;
      } else if (soc->state_o.at(0) == 0) {
        timeout = true;
        std::cerr << "Verification error, core not performing correctly."
                  << std::endl;
        goto finish;
      } else if (soc->state_o.at(0) == 3 && (counter_start != 0)) {
        std::cerr << "tracing..." << std::endl;
        trace = true;
      } else if (soc->state_o.at(0) == 4) {
        trace = false;
      }
    }
    soc->clk = 1;
    soc->eval();
    if (trace) {
      m_trace->dump(simtime);
      simtime++;
    }

    soc->clk = 0;
    soc->eval();
    if (trace) {
      m_trace->dump(simtime);
      simtime++;
    }
  }

finish:
  std::cerr << "Simulation time: "
            << double(counter_end - counter_start) * (1.0 / kHz) << " ms"
            << std::endl;
  if (timeout) {
    printf("TIMEOUT\n");
  } else if (!failedOut) {
    printf("PASSED\n");
    std::cerr << counter_end - counter_start << " cycles to complete"
              << std::endl;
  } else if (failedOut) {
    printf("FAILED\n");
  }

  m_trace->close();
  delete soc;
  if (timeout | failedOut)
    return -1;
}