// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtop__Syms.h"


//======================

void Vtop::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void Vtop::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vtop__Syms* __restrict vlSymsp = static_cast<Vtop__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Vtop::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void Vtop::traceInitTop(void* userp, VerilatedVcd* tracep) {
    Vtop__Syms* __restrict vlSymsp = static_cast<Vtop__Syms*>(userp);
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void Vtop::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    Vtop__Syms* __restrict vlSymsp = static_cast<Vtop__Syms*>(userp);
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBit(c+27,"sys_clock_i", false,-1);
        tracep->declBit(c+28,"uart_rx", false,-1);
        tracep->declBit(c+29,"uart_tx", false,-1);
        tracep->declBit(c+27,"top sys_clock_i", false,-1);
        tracep->declBit(c+28,"top uart_rx", false,-1);
        tracep->declBit(c+29,"top uart_tx", false,-1);
        tracep->declBus(c+1,"top rx_byte", false,-1, 7,0);
        tracep->declBit(c+2,"top rx", false,-1);
        tracep->declBit(c+3,"top tx_dequeue_o", false,-1);
        tracep->declBit(c+27,"top uart_rx_inst clock", false,-1);
        tracep->declBit(c+30,"top uart_rx_inst resetn", false,-1);
        tracep->declBus(c+31,"top uart_rx_inst bauddiv_i", false,-1, 15,0);
        tracep->declBit(c+28,"top uart_rx_inst rx_i", false,-1);
        tracep->declBus(c+1,"top uart_rx_inst rx_byte_o", false,-1, 7,0);
        tracep->declBit(c+2,"top uart_rx_inst rx_o", false,-1);
        tracep->declBit(c+4,"top uart_rx_inst rx_busy_o", false,-1);
        tracep->declBit(c+5,"top uart_rx_inst rx_q", false,-1);
        tracep->declBit(c+6,"top uart_rx_inst rx_qq", false,-1);
        tracep->declBit(c+7,"top uart_rx_inst sample_q", false,-1);
        tracep->declBit(c+8,"top uart_rx_inst start_q", false,-1);
        tracep->declBit(c+9,"top uart_rx_inst stop_q", false,-1);
        tracep->declBit(c+10,"top uart_rx_inst hbit_q", false,-1);
        tracep->declBit(c+2,"top uart_rx_inst cmpl_q", false,-1);
        tracep->declBus(c+11,"top uart_rx_inst counter_q", false,-1, 15,0);
        tracep->declBus(c+1,"top uart_rx_inst rx_byte_q", false,-1, 7,0);
        tracep->declBus(c+12,"top uart_rx_inst byte_cnt_q", false,-1, 2,0);
        tracep->declBit(c+13,"top uart_rx_inst rx", false,-1);
        tracep->declBit(c+14,"top uart_rx_inst zero", false,-1);
        tracep->declBit(c+15,"top uart_rx_inst sample_en", false,-1);
        tracep->declBit(c+16,"top uart_rx_inst shift_en", false,-1);
        tracep->declBit(c+17,"top uart_rx_inst last_shift", false,-1);
        tracep->declBit(c+27,"top uart_tx_inst clock", false,-1);
        tracep->declBit(c+30,"top uart_tx_inst resetn", false,-1);
        tracep->declBus(c+31,"top uart_tx_inst bauddiv_i", false,-1, 15,0);
        tracep->declBit(c+2,"top uart_tx_inst tx_i", false,-1);
        tracep->declBus(c+1,"top uart_tx_inst tx_byte_i", false,-1, 7,0);
        tracep->declBit(c+3,"top uart_tx_inst tx_dequeue_o", false,-1);
        tracep->declBit(c+29,"top uart_tx_inst tx_o", false,-1);
        tracep->declBit(c+18,"top uart_tx_inst tx_busy_o", false,-1);
        tracep->declBit(c+19,"top uart_tx_inst start_q", false,-1);
        tracep->declBit(c+20,"top uart_tx_inst byte_q", false,-1);
        tracep->declBit(c+21,"top uart_tx_inst stop_q", false,-1);
        tracep->declBit(c+3,"top uart_tx_inst cmpl_q", false,-1);
        tracep->declBit(c+22,"top uart_tx_inst tx_q", false,-1);
        tracep->declBus(c+23,"top uart_tx_inst counter_q", false,-1, 15,0);
        tracep->declBus(c+24,"top uart_tx_inst tx_byte_q", false,-1, 7,0);
        tracep->declBus(c+25,"top uart_tx_inst byte_cnt_q", false,-1, 2,0);
        tracep->declBit(c+26,"top uart_tx_inst zero", false,-1);
    }
}

void Vtop::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void Vtop::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    Vtop__Syms* __restrict vlSymsp = static_cast<Vtop__Syms*>(userp);
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void Vtop::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    Vtop__Syms* __restrict vlSymsp = static_cast<Vtop__Syms*>(userp);
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullCData(oldp+1,(vlTOPp->top__DOT__uart_rx_inst__DOT__rx_byte_q),8);
        tracep->fullBit(oldp+2,(vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q));
        tracep->fullBit(oldp+3,(vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q));
        tracep->fullBit(oldp+4,((((((IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__sample_q) 
                                    | (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__start_q)) 
                                   | (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__stop_q)) 
                                  | (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__hbit_q)) 
                                 | (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q))));
        tracep->fullBit(oldp+5,(vlTOPp->top__DOT__uart_rx_inst__DOT__rx_q));
        tracep->fullBit(oldp+6,(vlTOPp->top__DOT__uart_rx_inst__DOT__rx_qq));
        tracep->fullBit(oldp+7,(vlTOPp->top__DOT__uart_rx_inst__DOT__sample_q));
        tracep->fullBit(oldp+8,(vlTOPp->top__DOT__uart_rx_inst__DOT__start_q));
        tracep->fullBit(oldp+9,(vlTOPp->top__DOT__uart_rx_inst__DOT__stop_q));
        tracep->fullBit(oldp+10,(vlTOPp->top__DOT__uart_rx_inst__DOT__hbit_q));
        tracep->fullSData(oldp+11,(vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q),16);
        tracep->fullCData(oldp+12,(vlTOPp->top__DOT__uart_rx_inst__DOT__byte_cnt_q),3);
        tracep->fullBit(oldp+13,((1U & (~ (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__rx_qq)))));
        tracep->fullBit(oldp+14,((0U == (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q))));
        tracep->fullBit(oldp+15,((0x1b1U == (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q))));
        tracep->fullBit(oldp+16,(vlTOPp->top__DOT__uart_rx_inst__DOT__shift_en));
        tracep->fullBit(oldp+17,(((7U == (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__byte_cnt_q)) 
                                  & (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__shift_en))));
        tracep->fullBit(oldp+18,(((((IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__start_q) 
                                    | (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__byte_q)) 
                                   | (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__stop_q)) 
                                  | (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q))));
        tracep->fullBit(oldp+19,(vlTOPp->top__DOT__uart_tx_inst__DOT__start_q));
        tracep->fullBit(oldp+20,(vlTOPp->top__DOT__uart_tx_inst__DOT__byte_q));
        tracep->fullBit(oldp+21,(vlTOPp->top__DOT__uart_tx_inst__DOT__stop_q));
        tracep->fullBit(oldp+22,(vlTOPp->top__DOT__uart_tx_inst__DOT__tx_q));
        tracep->fullSData(oldp+23,(vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q),16);
        tracep->fullCData(oldp+24,(vlTOPp->top__DOT__uart_tx_inst__DOT__tx_byte_q),8);
        tracep->fullCData(oldp+25,(vlTOPp->top__DOT__uart_tx_inst__DOT__byte_cnt_q),3);
        tracep->fullBit(oldp+26,((0U == (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q))));
        tracep->fullBit(oldp+27,(vlTOPp->sys_clock_i));
        tracep->fullBit(oldp+28,(vlTOPp->uart_rx));
        tracep->fullBit(oldp+29,(vlTOPp->uart_tx));
        tracep->fullBit(oldp+30,(1U));
        tracep->fullSData(oldp+31,(0x363U),16);
    }
}
