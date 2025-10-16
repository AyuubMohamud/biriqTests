// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary design header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef _VTOP_H_
#define _VTOP_H_  // guard

#include "verilated.h"

//==========

class Vtop__Syms;
class Vtop_VerilatedVcd;


//----------

VL_MODULE(Vtop) {
  public:
    
    // PORTS
    // The application code writes and reads these signals to
    // propagate new values into/out from the Verilated model.
    VL_IN8(sys_clock_i,0,0);
    VL_IN8(uart_rx,0,0);
    VL_OUT8(uart_tx,0,0);
    
    // LOCAL SIGNALS
    // Internals; generally not touched by application code
    CData/*0:0*/ top__DOT__rx;
    CData/*0:0*/ top__DOT__uart_rx_inst__DOT__rx_q;
    CData/*0:0*/ top__DOT__uart_rx_inst__DOT__rx_qq;
    CData/*0:0*/ top__DOT__uart_rx_inst__DOT__sample_q;
    CData/*0:0*/ top__DOT__uart_rx_inst__DOT__start_q;
    CData/*0:0*/ top__DOT__uart_rx_inst__DOT__stop_q;
    CData/*0:0*/ top__DOT__uart_rx_inst__DOT__hbit_q;
    CData/*0:0*/ top__DOT__uart_rx_inst__DOT__cmpl_q;
    CData/*7:0*/ top__DOT__uart_rx_inst__DOT__rx_byte_q;
    CData/*2:0*/ top__DOT__uart_rx_inst__DOT__byte_cnt_q;
    CData/*0:0*/ top__DOT__uart_rx_inst__DOT__zero;
    CData/*0:0*/ top__DOT__uart_rx_inst__DOT__sample_en;
    CData/*0:0*/ top__DOT__uart_rx_inst__DOT__shift_en;
    CData/*0:0*/ top__DOT__uart_tx_inst__DOT__start_q;
    CData/*0:0*/ top__DOT__uart_tx_inst__DOT__byte_q;
    CData/*0:0*/ top__DOT__uart_tx_inst__DOT__stop_q;
    CData/*0:0*/ top__DOT__uart_tx_inst__DOT__cmpl_q;
    CData/*0:0*/ top__DOT__uart_tx_inst__DOT__tx_q;
    CData/*7:0*/ top__DOT__uart_tx_inst__DOT__tx_byte_q;
    CData/*2:0*/ top__DOT__uart_tx_inst__DOT__byte_cnt_q;
    CData/*0:0*/ top__DOT__uart_tx_inst__DOT__zero;
    SData/*15:0*/ top__DOT__uart_rx_inst__DOT__counter_q;
    SData/*15:0*/ top__DOT__uart_tx_inst__DOT__counter_q;
    
    // LOCAL VARIABLES
    // Internals; generally not touched by application code
    CData/*0:0*/ __Vclklast__TOP__sys_clock_i;
    CData/*0:0*/ __Vm_traceActivity[2];
    
    // INTERNAL VARIABLES
    // Internals; generally not touched by application code
    Vtop__Syms* __VlSymsp;  // Symbol table
    
    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(Vtop);  ///< Copying not allowed
  public:
    /// Construct the model; called by application code
    /// The special name  may be used to make a wrapper with a
    /// single model invisible with respect to DPI scope names.
    Vtop(const char* name = "TOP");
    /// Destroy the model; called (often implicitly) by application code
    ~Vtop();
    /// Trace signals in the model; called by application code
    void trace(VerilatedVcdC* tfp, int levels, int options = 0);
    
    // API METHODS
    /// Evaluate the model.  Application must call when inputs change.
    void eval() { eval_step(); }
    /// Evaluate when calling multiple units/models per time step.
    void eval_step();
    /// Evaluate at end of a timestep for tracing, when using eval_step().
    /// Application must call after all eval() and before time changes.
    void eval_end_step() {}
    /// Simulation complete, run final blocks.  Application must call on completion.
    void final();
    
    // INTERNAL METHODS
  private:
    static void _eval_initial_loop(Vtop__Syms* __restrict vlSymsp);
  public:
    void __Vconfigure(Vtop__Syms* symsp, bool first);
  private:
    static QData _change_request(Vtop__Syms* __restrict vlSymsp);
    static QData _change_request_1(Vtop__Syms* __restrict vlSymsp);
    void _ctor_var_reset() VL_ATTR_COLD;
  public:
    static void _eval(Vtop__Syms* __restrict vlSymsp);
  private:
#ifdef VL_DEBUG
    void _eval_debug_assertions();
#endif  // VL_DEBUG
  public:
    static void _eval_initial(Vtop__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _eval_settle(Vtop__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _initial__TOP__2(Vtop__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _sequent__TOP__1(Vtop__Syms* __restrict vlSymsp);
    static void _settle__TOP__3(Vtop__Syms* __restrict vlSymsp) VL_ATTR_COLD;
  private:
    static void traceChgSub0(void* userp, VerilatedVcd* tracep);
    static void traceChgTop0(void* userp, VerilatedVcd* tracep);
    static void traceCleanup(void* userp, VerilatedVcd* /*unused*/);
    static void traceFullSub0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceFullTop0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInitSub0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInitTop(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    void traceRegister(VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) VL_ATTR_COLD;
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard
