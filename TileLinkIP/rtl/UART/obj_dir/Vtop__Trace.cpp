// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtop__Syms.h"


void Vtop::traceChgTop0(void* userp, VerilatedVcd* tracep) {
    Vtop__Syms* __restrict vlSymsp = static_cast<Vtop__Syms*>(userp);
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    {
        vlTOPp->traceChgSub0(userp, tracep);
    }
}

void Vtop::traceChgSub0(void* userp, VerilatedVcd* tracep) {
    Vtop__Syms* __restrict vlSymsp = static_cast<Vtop__Syms*>(userp);
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode + 1);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        if (VL_UNLIKELY(vlTOPp->__Vm_traceActivity[1U])) {
            tracep->chgCData(oldp+0,(vlTOPp->top__DOT__uart_rx_inst__DOT__rx_byte_q),8);
            tracep->chgBit(oldp+1,(vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q));
            tracep->chgBit(oldp+2,(vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q));
            tracep->chgBit(oldp+3,((((((IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__sample_q) 
                                       | (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__start_q)) 
                                      | (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__stop_q)) 
                                     | (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__hbit_q)) 
                                    | (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q))));
            tracep->chgBit(oldp+4,(vlTOPp->top__DOT__uart_rx_inst__DOT__rx_q));
            tracep->chgBit(oldp+5,(vlTOPp->top__DOT__uart_rx_inst__DOT__rx_qq));
            tracep->chgBit(oldp+6,(vlTOPp->top__DOT__uart_rx_inst__DOT__sample_q));
            tracep->chgBit(oldp+7,(vlTOPp->top__DOT__uart_rx_inst__DOT__start_q));
            tracep->chgBit(oldp+8,(vlTOPp->top__DOT__uart_rx_inst__DOT__stop_q));
            tracep->chgBit(oldp+9,(vlTOPp->top__DOT__uart_rx_inst__DOT__hbit_q));
            tracep->chgSData(oldp+10,(vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q),16);
            tracep->chgCData(oldp+11,(vlTOPp->top__DOT__uart_rx_inst__DOT__byte_cnt_q),3);
            tracep->chgBit(oldp+12,((1U & (~ (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__rx_qq)))));
            tracep->chgBit(oldp+13,((0U == (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q))));
            tracep->chgBit(oldp+14,((0x1b1U == (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q))));
            tracep->chgBit(oldp+15,(vlTOPp->top__DOT__uart_rx_inst__DOT__shift_en));
            tracep->chgBit(oldp+16,(((7U == (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__byte_cnt_q)) 
                                     & (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__shift_en))));
            tracep->chgBit(oldp+17,(((((IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__start_q) 
                                       | (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__byte_q)) 
                                      | (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__stop_q)) 
                                     | (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q))));
            tracep->chgBit(oldp+18,(vlTOPp->top__DOT__uart_tx_inst__DOT__start_q));
            tracep->chgBit(oldp+19,(vlTOPp->top__DOT__uart_tx_inst__DOT__byte_q));
            tracep->chgBit(oldp+20,(vlTOPp->top__DOT__uart_tx_inst__DOT__stop_q));
            tracep->chgBit(oldp+21,(vlTOPp->top__DOT__uart_tx_inst__DOT__tx_q));
            tracep->chgSData(oldp+22,(vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q),16);
            tracep->chgCData(oldp+23,(vlTOPp->top__DOT__uart_tx_inst__DOT__tx_byte_q),8);
            tracep->chgCData(oldp+24,(vlTOPp->top__DOT__uart_tx_inst__DOT__byte_cnt_q),3);
            tracep->chgBit(oldp+25,((0U == (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q))));
        }
        tracep->chgBit(oldp+26,(vlTOPp->sys_clock_i));
        tracep->chgBit(oldp+27,(vlTOPp->uart_rx));
        tracep->chgBit(oldp+28,(vlTOPp->uart_tx));
    }
}

void Vtop::traceCleanup(void* userp, VerilatedVcd* /*unused*/) {
    Vtop__Syms* __restrict vlSymsp = static_cast<Vtop__Syms*>(userp);
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlSymsp->__Vm_activity = false;
        vlTOPp->__Vm_traceActivity[0U] = 0U;
        vlTOPp->__Vm_traceActivity[1U] = 0U;
    }
}
