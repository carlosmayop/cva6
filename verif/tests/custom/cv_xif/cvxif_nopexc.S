# See LICENSE for license details.

#*****************************************************************************
# Copyright 2022 Thales DIS design services SAS
#
# Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
# You may obtain a copy of the License at https:#solderpad.org/licenses/
#
#----------------------------------------------------------------------------------

#include "cvxif_macros.h"

  #-------------------------------------------------------------
  # Custom tests
  #-------------------------------------------------------------

  .globl main
main:

# core of the test

  li a0, 0x332211;
  li a1, 0xDEADBEEF;
  li a2, 0xDEADBEEF;

  .insn r CUSTOM_3, 0x1, 0x0, x10, x10, x11
  CUS_NOP;
  .insn r CUSTOM_3, 0x1, 0x0, x10, x10, x11
  .insn r CUSTOM_3, 0x1, 0x0, x10, x10, x11
  CUS_NOP;
  .insn r CUSTOM_3, 0x1, 0x0, x24, x28, x1
  .insn r CUSTOM_3, 0x1, 0x0, x7, x7, x3

# (example of) final self-check test
  li a0, 0xCAFE;
  li a1, 0xCAFE;
  xor a2, a0, a1;
  beqz a2, pass;

fail:
  # Failure post-processing (messages, ecall setup etc.)
  li a0, 0x0;
  jal exit;

pass:
  # Success post-processing (messages, ecall setup etc.)
  li a0, 0x0;
  jal exit;
