#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include "Vtesttop.h"
#include "/opt/oss-cad-suite/share/verilator/include/verilated_vcd_c.h"
vluint64_t simtime = 0;

int main() {
    Vtesttop* soc = new Vtesttop;
    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    soc->trace(m_trace, 15);
    m_trace->open("trace.vcd");
    soc->eval();
    bool failedOut = true;
    for (vluint64_t i = 0; i < 100000; i++) {
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
    if (soc->state_o.at(0)==0x00000032 && !failedOut) {
        printf("PASSED TEST: Test recursive functions\n");
    } else {
        printf("FAIL: Value was 0x%04X\n", soc->state_o.at(0));
        return -1;
    }
    m_trace->close();
    delete soc;
}