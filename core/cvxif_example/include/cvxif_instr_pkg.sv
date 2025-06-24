// Copyright 2021 Thales DIS design services SAS
//
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
// You may obtain a copy of the License at https://solderpad.org/licenses/
//
// Original Author: Guillaume Chauvon (guillaume.chauvon@thalesgroup.com)



package cvxif_instr_pkg;

  typedef enum logic [3:0] {
    ILLEGAL = 4'b0000,
    NOP = 4'b0001,
    FXMADD = 4'b0010,
    FXSEED = 4'b0011,
    FXGEN = 4'b0100
  } opcode_t;

  typedef enum logic [2:0] {
    NONE = 2'b00,
    LFSR_SEED = 2'b01,
    LFSR_GEN = 2'b10
  } lfsr_mode_t;

  typedef struct packed {
    logic accept;
    logic writeback;  // TODO depends on dualwrite
    logic [2:0] register_read;  // TODO Nr read ports
  } issue_resp_t;

  typedef struct packed {
    logic        accept;
    logic [31:0] instr;
  } compressed_resp_t;

  typedef struct packed {
    logic [31:0] instr;
    logic [31:0] mask;
    issue_resp_t resp;
    opcode_t     opcode;
  } copro_issue_resp_t;


  typedef struct packed {
    logic [15:0]      instr;
    logic [15:0]      mask;
    compressed_resp_t resp;
  } copro_compressed_resp_t;

  // 4 Possible RISCV instructions for Coprocessor
  parameter int unsigned NbInstr = 4;
  parameter copro_issue_resp_t CoproInstr[NbInstr] = '{
      '{
          // Custom Nop
          instr:
          32'b00000_00_00000_00000_0_00_00000_1111011,  // custom3 opcode
          mask: 32'b11111_11_00000_00000_1_11_00000_1111111,
          resp : '{accept : 1'b1, writeback : 1'b0, register_read : {1'b0, 1'b0, 1'b0}},
          opcode : NOP
      },
      '{
          // Custom FXMADD
          instr:
          32'b00000_00_00000_00000_000_00000_0101011,  // custom1 opcode
          mask: 32'b00000_00_00000_00000_000_00000_1111111,
          resp: '{accept : 1'b1, writeback : 1'b1, register_read : {1'b1, 1'b1, 1'b1}},
          opcode: FXMADD
      },
      '{
        // Custom FXGEN
        instr:
        32'b00000_00_00000_00000_000_00000_0001011, // custom0 opcode
        mask: 32'b11111_00_11111_11111_000_00000_1111111,
        resp: '{accept : 1'b1, writeback : 1'b1, register_read : {1'b0, 1'b0, 1'b0}},
        opcode: FXGEN
      },
      '{
        // Custom FXSEED
        instr:
        32'b1000000_00000_00000_000_00000_0001011, // custom0 opcode
        mask: 32'b1111111_11111_00000_111_11111_1111111,
        resp: '{accept : 1'b1, writeback : 1'b0, register_read : {1'b0, 1'b0, 1'b1}},
        opcode: FXSEED
      }
  };

  parameter int unsigned NbCompInstr = 2;
  parameter copro_compressed_resp_t CoproCompInstr[NbCompInstr] = '{
      // C_NOP
      '{
          instr : 16'b111_0_00000_00000_00,
          mask : 16'b111_1_00000_00000_11,
          resp : '{accept : 1'b1, instr : 32'b00000_00_00000_00000_0_00_00000_1111011}
      },
      '{
          instr : 16'b111_1_00000_00000_00,
          mask : 16'b111_1_00000_00000_11,
          resp : '{accept : 1'b1, instr : 32'b00000_00_00000_00000_0_01_01010_1111011}
      }
  };

endpackage
