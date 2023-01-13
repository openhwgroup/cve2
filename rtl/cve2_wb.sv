// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * Writeback passthrough
 *
 * The writeback stage is not present therefore this module acts as
 * a simple passthrough to write data direct to the register file.
 */

`include "prim_assert.sv"
`include "dv_fcov_macros.svh"

module cve2_wb #(
) (
  input  logic                     clk_i,
  input  logic                     rst_ni,

  input  logic                     en_wb_i,
  input  cve2_pkg::wb_instr_type_e instr_type_wb_i,
  input  logic [31:0]              pc_id_i,
  input  logic                     instr_is_compressed_id_i,
  input  logic                     instr_perf_count_id_i,

  output logic                     ready_wb_o,
  output logic                     rf_write_wb_o,
  output logic                     outstanding_load_wb_o,
  output logic                     outstanding_store_wb_o,
  output logic [31:0]              pc_wb_o,
  output logic                     perf_instr_ret_wb_o,
  output logic                     perf_instr_ret_compressed_wb_o,
  output logic                     perf_instr_ret_wb_spec_o,
  output logic                     perf_instr_ret_compressed_wb_spec_o,

  input  logic [4:0]               rf_waddr_id_i,
  input  logic [31:0]              rf_wdata_id_i,
  input  logic                     rf_we_id_i,

  input  logic [31:0]              rf_wdata_lsu_i,
  input  logic                     rf_we_lsu_i,

  output logic [31:0]              rf_wdata_fwd_wb_o,

  output logic [4:0]               rf_waddr_wb_o,
  output logic [31:0]              rf_wdata_wb_o,
  output logic                     rf_we_wb_o,

  input logic                      lsu_resp_valid_i,
  input logic                      lsu_resp_err_i,

  output logic                     instr_done_wb_o
);

  import cve2_pkg::*;

  // 0 == RF write from ID
  // 1 == RF write from LSU
  logic [31:0] rf_wdata_wb_mux    [2];
  logic [1:0]  rf_wdata_wb_mux_we;

  begin : g_bypass_wb
    // without writeback stage just pass through register write signals
    assign rf_waddr_wb_o         = rf_waddr_id_i;
    assign rf_wdata_wb_mux[0]    = rf_wdata_id_i;
    assign rf_wdata_wb_mux_we[0] = rf_we_id_i;

    // Increment instruction retire counters for valid instructions which are not lsu errors.
    // The speculative signals are always 0 when no writeback stage is present as the raw counter
    // values will be correct.
    assign perf_instr_ret_wb_spec_o            = 1'b0;
    assign perf_instr_ret_compressed_wb_spec_o = 1'b0;
    assign perf_instr_ret_wb_o                 = instr_perf_count_id_i & en_wb_i &
                                                 ~(lsu_resp_valid_i & lsu_resp_err_i);
    assign perf_instr_ret_compressed_wb_o      = perf_instr_ret_wb_o & instr_is_compressed_id_i;

    // ready needs to be constant 1 without writeback stage (otherwise ID/EX stage will stall)
    assign ready_wb_o    = 1'b1;

    // Unused Writeback stage only IO & wiring
    // Assign inputs and internal wiring to unused signals to satisfy lint checks
    // Tie-off outputs to constant values
    logic           unused_clk;
    logic           unused_rst;
    wb_instr_type_e unused_instr_type_wb;
    logic [31:0]    unused_pc_id;

    assign unused_clk            = clk_i;
    assign unused_rst            = rst_ni;
    assign unused_instr_type_wb  = instr_type_wb_i;
    assign unused_pc_id          = pc_id_i;

    assign outstanding_load_wb_o  = 1'b0;
    assign outstanding_store_wb_o = 1'b0;
    assign pc_wb_o                = '0;
    assign rf_write_wb_o          = 1'b0;
    assign rf_wdata_fwd_wb_o      = 32'b0;
    assign instr_done_wb_o        = 1'b0;
  end

  assign rf_wdata_wb_mux[1]    = rf_wdata_lsu_i;
  assign rf_wdata_wb_mux_we[1] = rf_we_lsu_i;

  // RF write data can come from ID results (all RF writes that aren't because of loads will come
  // from here) or the LSU (RF writes for load data)
  assign rf_wdata_wb_o = ({32{rf_wdata_wb_mux_we[0]}} & rf_wdata_wb_mux[0]) |
                         ({32{rf_wdata_wb_mux_we[1]}} & rf_wdata_wb_mux[1]);
  assign rf_we_wb_o    = |rf_wdata_wb_mux_we;

  `DV_FCOV_SIGNAL_GEN_IF(logic, wb_valid, g_writeback_stage.wb_valid_q, 1'b0)

  `ASSERT(RFWriteFromOneSourceOnly, $onehot0(rf_wdata_wb_mux_we))
endmodule
