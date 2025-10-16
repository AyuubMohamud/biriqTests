// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtop.h for the primary calling header

#include "Vtop.h"
#include "Vtop__Syms.h"

//==========

void Vtop::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vtop::eval\n"); );
    Vtop__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
#ifdef VL_DEBUG
    // Debug assertions
    _eval_debug_assertions();
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        vlSymsp->__Vm_activity = true;
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("top.sv", 1, "",
                "Verilated model didn't converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

void Vtop::_eval_initial_loop(Vtop__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    vlSymsp->__Vm_activity = true;
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        _eval_settle(vlSymsp);
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("top.sv", 1, "",
                "Verilated model didn't DC converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

VL_INLINE_OPT void Vtop::_sequent__TOP__1(Vtop__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop::_sequent__TOP__1\n"); );
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    CData/*0:0*/ __Vdly__top__DOT__uart_rx_inst__DOT__sample_q;
    CData/*0:0*/ __Vdly__top__DOT__uart_rx_inst__DOT__start_q;
    CData/*7:0*/ __Vdly__top__DOT__uart_rx_inst__DOT__rx_byte_q;
    CData/*2:0*/ __Vdly__top__DOT__uart_rx_inst__DOT__byte_cnt_q;
    CData/*0:0*/ __Vdly__top__DOT__uart_rx_inst__DOT__stop_q;
    CData/*0:0*/ __Vdly__top__DOT__uart_rx_inst__DOT__hbit_q;
    CData/*0:0*/ __Vdly__top__DOT__uart_tx_inst__DOT__start_q;
    CData/*0:0*/ __Vdly__top__DOT__uart_tx_inst__DOT__byte_q;
    CData/*0:0*/ __Vdly__top__DOT__uart_tx_inst__DOT__stop_q;
    CData/*2:0*/ __Vdly__top__DOT__uart_tx_inst__DOT__byte_cnt_q;
    CData/*7:0*/ __Vdly__top__DOT__uart_tx_inst__DOT__tx_byte_q;
    CData/*0:0*/ __Vdly__top__DOT__uart_tx_inst__DOT__cmpl_q;
    SData/*15:0*/ __Vdly__top__DOT__uart_rx_inst__DOT__counter_q;
    SData/*15:0*/ __Vdly__top__DOT__uart_tx_inst__DOT__counter_q;
    // Body
    __Vdly__top__DOT__uart_tx_inst__DOT__cmpl_q = vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q;
    __Vdly__top__DOT__uart_tx_inst__DOT__byte_cnt_q 
        = vlTOPp->top__DOT__uart_tx_inst__DOT__byte_cnt_q;
    __Vdly__top__DOT__uart_tx_inst__DOT__byte_q = vlTOPp->top__DOT__uart_tx_inst__DOT__byte_q;
    __Vdly__top__DOT__uart_tx_inst__DOT__stop_q = vlTOPp->top__DOT__uart_tx_inst__DOT__stop_q;
    __Vdly__top__DOT__uart_tx_inst__DOT__counter_q 
        = vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q;
    __Vdly__top__DOT__uart_tx_inst__DOT__start_q = vlTOPp->top__DOT__uart_tx_inst__DOT__start_q;
    __Vdly__top__DOT__uart_rx_inst__DOT__byte_cnt_q 
        = vlTOPp->top__DOT__uart_rx_inst__DOT__byte_cnt_q;
    __Vdly__top__DOT__uart_rx_inst__DOT__hbit_q = vlTOPp->top__DOT__uart_rx_inst__DOT__hbit_q;
    __Vdly__top__DOT__uart_rx_inst__DOT__stop_q = vlTOPp->top__DOT__uart_rx_inst__DOT__stop_q;
    __Vdly__top__DOT__uart_tx_inst__DOT__tx_byte_q 
        = vlTOPp->top__DOT__uart_tx_inst__DOT__tx_byte_q;
    __Vdly__top__DOT__uart_rx_inst__DOT__rx_byte_q 
        = vlTOPp->top__DOT__uart_rx_inst__DOT__rx_byte_q;
    __Vdly__top__DOT__uart_rx_inst__DOT__sample_q = vlTOPp->top__DOT__uart_rx_inst__DOT__sample_q;
    __Vdly__top__DOT__uart_rx_inst__DOT__start_q = vlTOPp->top__DOT__uart_rx_inst__DOT__start_q;
    __Vdly__top__DOT__uart_rx_inst__DOT__counter_q 
        = vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q;
    if (vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q) {
        __Vdly__top__DOT__uart_tx_inst__DOT__cmpl_q = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q)))) {
            __Vdly__top__DOT__uart_tx_inst__DOT__cmpl_q 
                = ((IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__stop_q) 
                   & (0U == (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q)));
        }
    }
    if (vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q) {
        __Vdly__top__DOT__uart_tx_inst__DOT__byte_cnt_q = 0U;
    } else {
        if (((IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__byte_q) 
             & (0U == (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q)))) {
            __Vdly__top__DOT__uart_tx_inst__DOT__byte_cnt_q 
                = (7U & ((IData)(1U) + (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__byte_cnt_q)));
        }
    }
    if (vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q) {
        __Vdly__top__DOT__uart_tx_inst__DOT__byte_q = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__byte_q)))) {
            __Vdly__top__DOT__uart_tx_inst__DOT__byte_q 
                = ((IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__start_q) 
                   & (0U == (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q)));
        }
    }
    if (vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q) {
        __Vdly__top__DOT__uart_tx_inst__DOT__stop_q = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__stop_q)))) {
            __Vdly__top__DOT__uart_tx_inst__DOT__stop_q 
                = (((IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__byte_q) 
                    & (0U == (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q))) 
                   & (7U == (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__byte_cnt_q)));
        }
    }
    if (((((IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__start_q) 
           | (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__stop_q)) 
          | (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__byte_q)) 
         | (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q))) {
        if (vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q) {
            vlTOPp->top__DOT__uart_tx_inst__DOT__tx_q = 1U;
        } else {
            if (vlTOPp->top__DOT__uart_tx_inst__DOT__stop_q) {
                vlTOPp->top__DOT__uart_tx_inst__DOT__tx_q = 1U;
            } else {
                if (vlTOPp->top__DOT__uart_tx_inst__DOT__byte_q) {
                    vlTOPp->top__DOT__uart_tx_inst__DOT__tx_q 
                        = (1U & (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__tx_byte_q));
                } else {
                    if (vlTOPp->top__DOT__uart_tx_inst__DOT__start_q) {
                        vlTOPp->top__DOT__uart_tx_inst__DOT__tx_q = 0U;
                    }
                }
            }
        }
    } else {
        vlTOPp->top__DOT__uart_tx_inst__DOT__tx_q = 1U;
    }
    __Vdly__top__DOT__uart_tx_inst__DOT__counter_q 
        = ((1U & (((~ (((IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__start_q) 
                        | (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__byte_q)) 
                       | (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__stop_q))) 
                   | (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__zero)) 
                  | (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q)))
            ? 0x363U : (0xffffU & ((IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q) 
                                   - (IData)(1U))));
    if (vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q) {
        __Vdly__top__DOT__uart_tx_inst__DOT__start_q = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__start_q)))) {
            __Vdly__top__DOT__uart_tx_inst__DOT__start_q 
                = vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q;
        }
    }
    if (vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q) {
        __Vdly__top__DOT__uart_rx_inst__DOT__byte_cnt_q = 0U;
    } else {
        if (vlTOPp->top__DOT__uart_rx_inst__DOT__shift_en) {
            __Vdly__top__DOT__uart_rx_inst__DOT__byte_cnt_q 
                = (7U & ((IData)(1U) + (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__byte_cnt_q)));
        }
    }
    if (vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q) {
        __Vdly__top__DOT__uart_rx_inst__DOT__hbit_q = 0U;
    } else {
        if (((IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__stop_q) 
             & (0U == (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q)))) {
            __Vdly__top__DOT__uart_rx_inst__DOT__hbit_q = 1U;
        }
    }
    if (vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q) {
        __Vdly__top__DOT__uart_rx_inst__DOT__stop_q = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__stop_q)))) {
            __Vdly__top__DOT__uart_rx_inst__DOT__stop_q 
                = ((7U == (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__byte_cnt_q)) 
                   & (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__shift_en));
        }
    }
    if (vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q) {
        __Vdly__top__DOT__uart_tx_inst__DOT__tx_byte_q 
            = vlTOPp->top__DOT__uart_rx_inst__DOT__rx_byte_q;
    } else {
        if (((IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__byte_q) 
             & (0U == (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q)))) {
            __Vdly__top__DOT__uart_tx_inst__DOT__tx_byte_q 
                = (0x7fU & ((IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__tx_byte_q) 
                            >> 1U));
        }
    }
    if (vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q) {
        __Vdly__top__DOT__uart_rx_inst__DOT__rx_byte_q = 0U;
    } else {
        if (vlTOPp->top__DOT__uart_rx_inst__DOT__shift_en) {
            __Vdly__top__DOT__uart_rx_inst__DOT__rx_byte_q 
                = (((IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__rx_qq) 
                    << 7U) | (0x7fU & ((IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__rx_byte_q) 
                                       >> 1U)));
        }
    }
    if (vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q) {
        __Vdly__top__DOT__uart_rx_inst__DOT__sample_q = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__sample_q)))) {
            __Vdly__top__DOT__uart_rx_inst__DOT__sample_q 
                = (1U & (~ (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__rx_qq)));
        }
    }
    if (vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q) {
        __Vdly__top__DOT__uart_rx_inst__DOT__start_q = 0U;
    } else {
        if ((1U & (~ (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__start_q)))) {
            __Vdly__top__DOT__uart_rx_inst__DOT__start_q 
                = (((0x1b1U == (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q)) 
                    & (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__sample_q)) 
                   & (~ (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__rx_qq)));
        }
    }
    __Vdly__top__DOT__uart_rx_inst__DOT__counter_q 
        = ((((((IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__rx_qq) 
               & (~ ((IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__sample_q) 
                     | (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__start_q)))) 
              | (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__zero)) 
             | ((((IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__sample_en) 
                  & (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__sample_q)) 
                 & (~ (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__rx_qq))) 
                & (~ (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__start_q)))) 
            | (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q))
            ? 0x363U : (0xffffU & ((IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q) 
                                   - (IData)(1U))));
    vlTOPp->top__DOT__uart_tx_inst__DOT__byte_cnt_q 
        = __Vdly__top__DOT__uart_tx_inst__DOT__byte_cnt_q;
    vlTOPp->top__DOT__uart_tx_inst__DOT__stop_q = __Vdly__top__DOT__uart_tx_inst__DOT__stop_q;
    vlTOPp->top__DOT__uart_tx_inst__DOT__start_q = __Vdly__top__DOT__uart_tx_inst__DOT__start_q;
    vlTOPp->top__DOT__uart_tx_inst__DOT__cmpl_q = __Vdly__top__DOT__uart_tx_inst__DOT__cmpl_q;
    vlTOPp->top__DOT__uart_rx_inst__DOT__stop_q = __Vdly__top__DOT__uart_rx_inst__DOT__stop_q;
    vlTOPp->top__DOT__uart_rx_inst__DOT__byte_cnt_q 
        = __Vdly__top__DOT__uart_rx_inst__DOT__byte_cnt_q;
    vlTOPp->top__DOT__uart_tx_inst__DOT__tx_byte_q 
        = __Vdly__top__DOT__uart_tx_inst__DOT__tx_byte_q;
    vlTOPp->top__DOT__uart_tx_inst__DOT__byte_q = __Vdly__top__DOT__uart_tx_inst__DOT__byte_q;
    vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q 
        = __Vdly__top__DOT__uart_tx_inst__DOT__counter_q;
    vlTOPp->top__DOT__uart_rx_inst__DOT__rx_byte_q 
        = __Vdly__top__DOT__uart_rx_inst__DOT__rx_byte_q;
    vlTOPp->top__DOT__uart_rx_inst__DOT__start_q = __Vdly__top__DOT__uart_rx_inst__DOT__start_q;
    vlTOPp->top__DOT__uart_rx_inst__DOT__sample_q = __Vdly__top__DOT__uart_rx_inst__DOT__sample_q;
    vlTOPp->uart_tx = vlTOPp->top__DOT__uart_tx_inst__DOT__tx_q;
    vlTOPp->top__DOT__uart_tx_inst__DOT__zero = (0U 
                                                 == (IData)(vlTOPp->top__DOT__uart_tx_inst__DOT__counter_q));
    vlTOPp->top__DOT__uart_rx_inst__DOT__rx_qq = vlTOPp->top__DOT__uart_rx_inst__DOT__rx_q;
    if (vlTOPp->top__DOT__rx) {
        vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q = 0U;
    } else {
        if (((IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__hbit_q) 
             & (0x1b1U == (IData)(vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q)))) {
            vlTOPp->top__DOT__uart_rx_inst__DOT__cmpl_q = 1U;
        }
    }
    vlTOPp->top__DOT__uart_rx_inst__DOT__hbit_q = __Vdly__top__DOT__uart_rx_inst__DOT__hbit_q;
    vlTOPp->top__DOT__uart_rx_inst__DOT__counter_q 
        = __Vdly__top__DOT__uart_rx_inst__DOT__counter_q;
    vlTOPp->top__DOT__uart_rx_inst__DOT__rx_q = vlTOPp->uart_rx;
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

void Vtop::_eval(Vtop__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop::_eval\n"); );
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if (((IData)(vlTOPp->sys_clock_i) & (~ (IData)(vlTOPp->__Vclklast__TOP__sys_clock_i)))) {
        vlTOPp->_sequent__TOP__1(vlSymsp);
        vlTOPp->__Vm_traceActivity[1U] = 1U;
    }
    // Final
    vlTOPp->__Vclklast__TOP__sys_clock_i = vlTOPp->sys_clock_i;
}

VL_INLINE_OPT QData Vtop::_change_request(Vtop__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop::_change_request\n"); );
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    return (vlTOPp->_change_request_1(vlSymsp));
}

VL_INLINE_OPT QData Vtop::_change_request_1(Vtop__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop::_change_request_1\n"); );
    Vtop* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}

#ifdef VL_DEBUG
void Vtop::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop::_eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((sys_clock_i & 0xfeU))) {
        Verilated::overWidthError("sys_clock_i");}
    if (VL_UNLIKELY((uart_rx & 0xfeU))) {
        Verilated::overWidthError("uart_rx");}
}
#endif  // VL_DEBUG
