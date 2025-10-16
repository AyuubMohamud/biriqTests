#include "../model/SOFTUART.hpp"
#include "Vtop.h"
#include "verilated_vcd_c.h"
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#define BAUDRATE 100'000'000 / (115'200)
#define ONE_PL_HF BAUDRATE + (BAUDRATE / 2)
vluint64_t simtime = 0;

int main() {
  Vtop *soc = new Vtop;
  SOFTUART softuart(100'000'000, 115'200);
  char a_char[8] = {1, 0, 0, 0, 0, 1, 1, 0};
  Verilated::traceEverOn(true);
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  soc->trace(m_trace, 15);
  m_trace->open("trace.vcd");
  soc->eval();
  soc->uart_rx = 1;
  int k = 0;
  bool enableUART = 1;
  softuart.transmitSetup('p');
  for (vluint64_t i = 0; i < 80'000; i++) {
    soc->sys_clock_i = 1;
    soc->eval();
    m_trace->dump(simtime);
    simtime++;
    soc->sys_clock_i = 0;
    soc->eval();
    m_trace->dump(simtime);
    simtime++;

    if (k <= 1000) {
      k++;
    } else {
      softuart.transmitEval(soc->uart_rx);
      bool l = softuart.recieveEval(soc->uart_tx);
      if (l)
        printf("%c\n", softuart.recieveValue());
    }
  }

  m_trace->close();
  delete soc;
}