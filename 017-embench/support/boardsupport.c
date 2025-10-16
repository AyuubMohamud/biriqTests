/* Copyright (C) 2017 Embecosm Limited and University of Bristol

   Contributor Graham Markall <graham.markall@embecosm.com>

   This file is part of Embench and was formerly part of the Bristol/Embecosm
   Embedded Benchmark Suite.

   SPDX-License-Identifier: GPL-3.0-or-later */

#include <support.h>

void initialise_board() { __asm__ volatile("li a0, 0" : : : "memory"); }

void __attribute__((noinline)) __attribute__((externally_visible))
start_trigger() {
  __asm__ volatile("li a0, 1\n"
                   "li a1, 0x80000000\n"
                   "sw a0, 0(a1)\n"
                   "sw zero, 16(a1)\n"
                   :
                   :
                   : "memory");
}
void __attribute__((noinline)) __attribute__((externally_visible))
start_debug() {
  __asm__ volatile("li a0, 3\n"
                   "li a1, 0x80000000\n"
                   "sw a0, 0(a1)\n"
                   "sw zero, 16(a1)\n"
                   :
                   :
                   : "memory");
}
void __attribute__((noinline)) __attribute__((externally_visible))
stop_debug() {
  __asm__ volatile("li a0, 4\n"
                   "li a1, 0x80000000\n"
                   "sw a0, 0(a1)\n"
                   "sw zero, 16(a1)\n"
                   :
                   :
                   : "memory");
}

void __attribute__((noinline)) __attribute__((externally_visible))
stop_trigger() {
  __asm__ volatile("li a0, 2\n"
                   "li a1, 0x80000000\n"
                   "sw a0, 0(a1)\n"
                   "sw zero, 16(a1)\n"
                   :
                   :
                   : "memory");
}
void __attribute__((noinline)) __attribute__((externally_visible)) fail() {
  __asm__ volatile("li a1, 0x80000000\n"
                   "sw zero, 0(a1)\n"
                   "sw zero, 16(a1)\n"
                   :
                   :
                   : "memory");
}