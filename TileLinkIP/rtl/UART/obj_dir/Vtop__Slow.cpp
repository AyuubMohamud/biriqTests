// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtop.h for the primary calling header

#include "Vtop.h"
#include "Vtop__Syms.h"

//==========

VL_CTOR_IMP(Vtop) {
    Vtop__Syms* __restrict vlSymsp = __VlSymsp = new Vtop__Syms(this, name());
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void Vtop::__Vconfigure(Vtop__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
    Verilated::timeunit(-12);
    Verilated::timeprecision(-12);
}

Vtop::~Vtop() {
    VL_DO_CLEAR(delete __VlSymsp, __VlSymsp = NULL);
}

void Vtop::_initial__TOP__2(Vtop__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop::_initial__TOP__2\n"); );
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->top__DOT__uart_tx_inst__DOT__start_q = 0U;
    vlTOPp->top__DOT__uart_tx_inst__DOT__byte_q = 0U;
    vlTOPp->top__DOT__uart_tx_inst__DOT__stop_q = 0U;
    vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q = 0U;
    vlTOPp->top__DOT__uart_tx_inst__DOT__tx_q = 1U;
    vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q = 0U;
    vlTOPp->top__DOT__uart_tx_inst__DOT__tx_byte_q = 0U;
    vlTOPp->top__DOT__uart_tx_inst__DOT__byte_cnt_q = 0U;
    vlTOPp->top__DOT__uart_rx_inst__DOT__rx_q = 1U;
    vlTOPp->top__DOT__uart_rx_inst__DOT__rx_qq = 1U;
    vlTOPp->top__DOT__uart_rx_inst__DOT__rx_byte_q = 0U;
    vlTOPp->top__DOT__uart_rx_inst__DOT__sample_q = 0U;
    vlTOPp->top__DOT__uart_rx_inst__DOT__start_q = 0U;
    vlTOPp->top__DOT__uart_rx_inst__DOT__byte_cnt_q = 0U;
    vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q = 0U;
    vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q = 0U;
}

void Vtop::_settle__TOP__3(Vtop__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop::_settle__TOP__3\n"); );
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->uart_tx = vlTOPp->top__DOT__uart_tx_inst__DOT__tx_q;
    vlTOPp->top__DOT__uart_tx_inst__DOT__zero = (0U 
                                                 == (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q));
    vlTOPp->top__DOT__rx = vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q;
    vlTOPp->top__DOT__uart_rx_inst__DOT__zero = (0U 
                                                 == (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q));
    vlTOPp->top__DOT__uart_rx_inst__DOT__sample_en 
        = (0x1b1U == (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q));
    vlTOPp->top__DOT__uart_rx_inst__DOT__shift_en = 
        ((((0U == (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q)) 
           & (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__sample_q)) 
          & (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__start_q)) 
         & (~ (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__stop_q)));
}

void Vtop::_eval_initial(Vtop__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop::_eval_initial\n"); );
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->__Vclklast__TOP__sys_clock_i = vlTOPp->sys_clock_i;
    vlTOPp->_initial__TOP__2(vlSymsp);
    vlTOPp->__Vm_traceActivity[1U] = 1U;
    vlTOPp->__Vm_traceActivity[0U] = 1U;
}

void Vtop::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop::final\n"); );
    // Variables
    Vtop__Syms* __restrict vlSymsp = this->__VlSymsp;
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vtop::_eval_settle(Vtop__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop::_eval_settle\n"); );
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_settle__TOP__3(vlSymsp);
    vlTOPp->__Vm_traceActivity[1U] = 1U;
    vlTOPp->__Vm_traceActivity[0U] = 1U;
}

void Vtop::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop::_ctor_var_reset\n"); );
    // Body
    sys_clock_i = VL_RAND_RESET_I(1);
    uart_rx = VL_RAND_RESET_I(1);
    uart_tx = VL_RAND_RESET_I(1);
    top__DOT__rx = VL_RAND_RESET_I(1);
    top__DOT__uart_rx_inst__DOT__rx_q = VL_RAND_RESET_I(1);
    top__DOT__uart_rx_inst__DOT__rx_qq = VL_RAND_RESET_I(1);
    top__DOT__uart_rx_inst__DOT__sample_q = VL_RAND_RESET_I(1);
    top__DOT__uart_rx_inst__DOT__start_q = VL_RAND_RESET_I(1);
    top__DOT__uart_rx_inst__DOT__stop_q = VL_RAND_RESET_I(1);
    top__DOT__uart_rx_inst__DOT__hbit_q = VL_RAND_RESET_I(1);
    top__DOT__uart_rx_inst__DOT__cmpl_q = VL_RAND_RESET_I(1);
    top__DOT__uart_rx_inst__DOT__counter_q = VL_RAND_RESET_I(16);
    top__DOT__uart_rx_inst__DOT__rx_byte_q = VL_RAND_RESET_I(8);
    top__DOT__uart_rx_inst__DOT__byte_cnt_q = VL_RAND_RESET_I(3);
    top__DOT__uart_rx_inst__DOT__zero = VL_RAND_RESET_I(1);
    top__DOT__uart_rx_inst__DOT__sample_en = VL_RAND_RESET_I(1);
    top__DOT__uart_rx_inst__DOT__shift_en = VL_RAND_RESET_I(1);
    top__DOT__uart_tx_inst__DOT__start_q = VL_RAND_RESET_I(1);
    top__DOT__uart_tx_inst__DOT__byte_q = VL_RAND_RESET_I(1);
    top__DOT__uart_tx_inst__DOT__stop_q = VL_RAND_RESET_I(1);
    top__DOT__uart_tx_inst__DOT__cmpl_q = VL_RAND_RESET_I(1);
    top__DOT__uart_tx_inst__DOT__tx_q = VL_RAND_RESET_I(1);
    top__DOT__uart_tx_inst__DOT__counter_q = VL_RAND_RESET_I(16);
    top__DOT__uart_tx_inst__DOT__tx_byte_q = VL_RAND_RESET_I(8);
    top__DOT__uart_tx_inst__DOT__byte_cnt_q = VL_RAND_RESET_I(3);
    top__DOT__uart_tx_inst__DOT__zero = VL_RAND_RESET_I(1);
    { int __Vi0=0; for (; __Vi0<2; ++__Vi0) {
            __Vm_traceActivity[__Vi0] = VL_RAND_RESET_I(1);
    }}
}
