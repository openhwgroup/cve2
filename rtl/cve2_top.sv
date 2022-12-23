// Copyright lowRISC contributors.
// Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`ifdef RISCV_FORMAL
  `define RVFI
`endif

`include "prim_assert.sv"

/**
 * Top level module of the ibex RISC-V core
 */
module cve2_top import cve2_pkg::*; #(
  parameter int unsigned MHPMCounterNum   = 0,
  parameter int unsigned MHPMCounterWidth = 40,
  parameter bit          RV32E            = 1'b0,
  parameter rv32m_e      RV32M            = RV32MFast,
  parameter regfile_e    RegFile          = RegFileFF,
  parameter bit          WritebackStage   = 1'b0,
  parameter bit          BranchPredictor  = 1'b0,
  parameter int unsigned DmHaltAddr       = 32'h1A110800,
  parameter int unsigned DmExceptionAddr  = 32'h1A110808
) (
  // Clock and Reset
  input  logic                         clk_i,
  input  logic                         rst_ni,

  input  logic                         test_en_i,     // enable all clock gates for testing
  input  prim_ram_1p_pkg::ram_1p_cfg_t ram_cfg_i,

  input  logic [31:0]                  hart_id_i,
  input  logic [31:0]                  boot_addr_i,

  // Instruction memory interface
  output logic                         instr_req_o,
  input  logic                         instr_gnt_i,
  input  logic                         instr_rvalid_i,
  output logic [31:0]                  instr_addr_o,
  input  logic [31:0]                  instr_rdata_i,
  input  logic [6:0]                   instr_rdata_intg_i,
  input  logic                         instr_err_i,

  // Data memory interface
  output logic                         data_req_o,
  input  logic                         data_gnt_i,
  input  logic                         data_rvalid_i,
  output logic                         data_we_o,
  output logic [3:0]                   data_be_o,
  output logic [31:0]                  data_addr_o,
  output logic [31:0]                  data_wdata_o,
  output logic [6:0]                   data_wdata_intg_o,
  input  logic [31:0]                  data_rdata_i,
  input  logic [6:0]                   data_rdata_intg_i,
  input  logic                         data_err_i,

  // Interrupt inputs
  input  logic                         irq_software_i,
  input  logic                         irq_timer_i,
  input  logic                         irq_external_i,
  input  logic [14:0]                  irq_fast_i,
  input  logic                         irq_nm_i,       // non-maskeable interrupt

  // Debug Interface
  input  logic                         debug_req_i,
  output crash_dump_t                  crash_dump_o,
  output logic                         double_fault_seen_o,

  // RISC-V Formal Interface
  // Does not comply with the coding standards of _i/_o suffixes, but follows
  // the convention of RISC-V Formal Interface Specification.
`ifdef RVFI
  output logic                         rvfi_valid,
  output logic [63:0]                  rvfi_order,
  output logic [31:0]                  rvfi_insn,
  output logic                         rvfi_trap,
  output logic                         rvfi_halt,
  output logic                         rvfi_intr,
  output logic [ 1:0]                  rvfi_mode,
  output logic [ 1:0]                  rvfi_ixl,
  output logic [ 4:0]                  rvfi_rs1_addr,
  output logic [ 4:0]                  rvfi_rs2_addr,
  output logic [ 4:0]                  rvfi_rs3_addr,
  output logic [31:0]                  rvfi_rs1_rdata,
  output logic [31:0]                  rvfi_rs2_rdata,
  output logic [31:0]                  rvfi_rs3_rdata,
  output logic [ 4:0]                  rvfi_rd_addr,
  output logic [31:0]                  rvfi_rd_wdata,
  output logic [31:0]                  rvfi_pc_rdata,
  output logic [31:0]                  rvfi_pc_wdata,
  output logic [31:0]                  rvfi_mem_addr,
  output logic [ 3:0]                  rvfi_mem_rmask,
  output logic [ 3:0]                  rvfi_mem_wmask,
  output logic [31:0]                  rvfi_mem_rdata,
  output logic [31:0]                  rvfi_mem_wdata,
  output logic [31:0]                  rvfi_ext_mip,
  output logic                         rvfi_ext_nmi,
  output logic                         rvfi_ext_debug_req,
  output logic [63:0]                  rvfi_ext_mcycle,
`endif

  // CPU Control Signals
  input  fetch_enable_t                fetch_enable_i,
  output logic                         alert_minor_o,
  output logic                         alert_major_internal_o,
  output logic                         alert_major_bus_o,
  output logic                         core_sleep_o,

  // DFT bypass controls
  input logic                          scan_rst_ni
);

  // Scrambling Parameter
  localparam int unsigned NumAddrScrRounds  = 0;
  localparam int unsigned NumDiffRounds     = NumAddrScrRounds;

  // Physical Memory Protection
  localparam bit          PMPEnable        = 1'b0;
  localparam int unsigned PMPGranularity   = 0;
  localparam int unsigned PMPNumRegions    = 4;

  // Trigger support
  localparam bit          DbgTriggerEn     = 1'b1;
  localparam int unsigned DbgHwBreakNum    = 1;

  // Bit manipulation extension
  localparam rv32b_e      RV32B            = RV32BNone;

  // Clock signals
  logic                        clk;
  logic                        core_busy_d, core_busy_q;
  logic                        clock_en;
  logic                        irq_pending;
  // Core <-> Register file signals
  logic                        dummy_instr_id;
  logic [4:0]                  rf_raddr_a;
  logic [4:0]                  rf_raddr_b;
  logic [4:0]                  rf_waddr_wb;
  logic                        rf_we_wb;
  logic [31:0] rf_wdata_wb_ecc;
  logic [31:0] rf_rdata_a_ecc, rf_rdata_a_ecc_buf;
  logic [31:0] rf_rdata_b_ecc, rf_rdata_b_ecc_buf;
  // Alert signals
  logic                        core_alert_major, core_alert_minor;
  logic                        lockstep_alert_major_internal, lockstep_alert_major_bus;
  logic                        lockstep_alert_minor;

  fetch_enable_t fetch_enable_buf;

  /////////////////////
  // Main clock gate //
  /////////////////////

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      core_busy_q <= 1'b0;
    end else begin
      core_busy_q <= core_busy_d;
    end
  end

  assign clock_en     = core_busy_q | debug_req_i | irq_pending | irq_nm_i;
  assign core_sleep_o = ~clock_en;

  prim_clock_gating core_clock_gate_i (
    .clk_i    (clk_i),
    .en_i     (clock_en),
    .test_en_i(test_en_i),
    .clk_o    (clk)
  );

  ////////////////////////
  // Core instantiation //
  ////////////////////////

  // Buffer security critical signals to prevent synthesis optimisation removing them
  prim_buf #(.Width($bits(fetch_enable_t))) u_fetch_enable_buf (
    .in_i (fetch_enable_i),
    .out_o(fetch_enable_buf)
  );

  prim_buf #(.Width(32)) u_rf_rdata_a_ecc_buf (
    .in_i (rf_rdata_a_ecc),
    .out_o(rf_rdata_a_ecc_buf)
  );

  prim_buf #(.Width(32)) u_rf_rdata_b_ecc_buf (
    .in_i (rf_rdata_b_ecc),
    .out_o(rf_rdata_b_ecc_buf)
  );

  cve2_core #(
    .PMPEnable        (PMPEnable),
    .PMPGranularity   (PMPGranularity),
    .PMPNumRegions    (PMPNumRegions),
    .MHPMCounterNum   (MHPMCounterNum),
    .MHPMCounterWidth (MHPMCounterWidth),
    .RV32E            (RV32E),
    .RV32M            (RV32M),
    .RV32B            (RV32B),
    .BranchPredictor  (BranchPredictor),
    .DbgTriggerEn     (DbgTriggerEn),
    .DbgHwBreakNum    (DbgHwBreakNum),
    .WritebackStage   (WritebackStage),
    .DmHaltAddr       (DmHaltAddr),
    .DmExceptionAddr  (DmExceptionAddr)
  ) u_cve2_core (
    .clk_i(clk),
    .rst_ni,

    .hart_id_i,
    .boot_addr_i,

    .instr_req_o,
    .instr_gnt_i,
    .instr_rvalid_i,
    .instr_addr_o,
    .instr_rdata_i,
    .instr_err_i,

    .data_req_o,
    .data_gnt_i,
    .data_rvalid_i,
    .data_we_o,
    .data_be_o,
    .data_addr_o,
    .data_wdata_o,
    .data_rdata_i,
    .data_err_i,

    .dummy_instr_id_o (dummy_instr_id),
    .rf_raddr_a_o     (rf_raddr_a),
    .rf_raddr_b_o     (rf_raddr_b),
    .rf_waddr_wb_o    (rf_waddr_wb),
    .rf_we_wb_o       (rf_we_wb),
    .rf_wdata_wb_ecc_o(rf_wdata_wb_ecc),
    .rf_rdata_a_ecc_i (rf_rdata_a_ecc_buf),
    .rf_rdata_b_ecc_i (rf_rdata_b_ecc_buf),

    .irq_software_i,
    .irq_timer_i,
    .irq_external_i,
    .irq_fast_i,
    .irq_nm_i,
    .irq_pending_o(irq_pending),

    .debug_req_i,
    .crash_dump_o,
    .double_fault_seen_o,

`ifdef RVFI
    .rvfi_valid,
    .rvfi_order,
    .rvfi_insn,
    .rvfi_trap,
    .rvfi_halt,
    .rvfi_intr,
    .rvfi_mode,
    .rvfi_ixl,
    .rvfi_rs1_addr,
    .rvfi_rs2_addr,
    .rvfi_rs3_addr,
    .rvfi_rs1_rdata,
    .rvfi_rs2_rdata,
    .rvfi_rs3_rdata,
    .rvfi_rd_addr,
    .rvfi_rd_wdata,
    .rvfi_pc_rdata,
    .rvfi_pc_wdata,
    .rvfi_mem_addr,
    .rvfi_mem_rmask,
    .rvfi_mem_wmask,
    .rvfi_mem_rdata,
    .rvfi_mem_wdata,
    .rvfi_ext_mip,
    .rvfi_ext_nmi,
    .rvfi_ext_debug_req,
    .rvfi_ext_mcycle,
`endif

    .fetch_enable_i(fetch_enable_buf),
    .alert_minor_o (core_alert_minor),
    .alert_major_o (core_alert_major),
    .core_busy_o   (core_busy_d)
  );

  /////////////////////////////////
  // Register file Instantiation //
  /////////////////////////////////

  if (RegFile == RegFileFF) begin : gen_regfile_ff
    cve2_register_file_ff #(
      .RV32E            (RV32E),
      .DataWidth        (32),
      .WordZeroVal      (32'(prim_secded_pkg::SecdedInv3932ZeroWord))
    ) register_file_i (
      .clk_i (clk),
      .rst_ni(rst_ni),

      .test_en_i       (test_en_i),
      .dummy_instr_id_i(dummy_instr_id),

      .raddr_a_i(rf_raddr_a),
      .rdata_a_o(rf_rdata_a_ecc),
      .raddr_b_i(rf_raddr_b),
      .rdata_b_o(rf_rdata_b_ecc),
      .waddr_a_i(rf_waddr_wb),
      .wdata_a_i(rf_wdata_wb_ecc),
      .we_a_i   (rf_we_wb)
    );
  end else if (RegFile == RegFileFPGA) begin : gen_regfile_fpga
    cve2_register_file_fpga #(
      .RV32E            (RV32E),
      .DataWidth        (32),
      .WordZeroVal      (32'(prim_secded_pkg::SecdedInv3932ZeroWord))
    ) register_file_i (
      .clk_i (clk),
      .rst_ni(rst_ni),

      .test_en_i       (test_en_i),
      .dummy_instr_id_i(dummy_instr_id),

      .raddr_a_i(rf_raddr_a),
      .rdata_a_o(rf_rdata_a_ecc),
      .raddr_b_i(rf_raddr_b),
      .rdata_b_o(rf_rdata_b_ecc),
      .waddr_a_i(rf_waddr_wb),
      .wdata_a_i(rf_wdata_wb_ecc),
      .we_a_i   (rf_we_wb)
    );
  end else if (RegFile == RegFileLatch) begin : gen_regfile_latch
    cve2_register_file_latch #(
      .RV32E            (RV32E),
      .DataWidth        (32),
      .WordZeroVal      (32'(prim_secded_pkg::SecdedInv3932ZeroWord))
    ) register_file_i (
      .clk_i (clk),
      .rst_ni(rst_ni),

      .test_en_i       (test_en_i),
      .dummy_instr_id_i(dummy_instr_id),

      .raddr_a_i(rf_raddr_a),
      .rdata_a_o(rf_rdata_a_ecc),
      .raddr_b_i(rf_raddr_b),
      .rdata_b_o(rf_rdata_b_ecc),
      .waddr_a_i(rf_waddr_wb),
      .wdata_a_i(rf_wdata_wb_ecc),
      .we_a_i   (rf_we_wb)
    );
  end

  ////////////////////////
  // Rams Instantiation //
  ////////////////////////

  begin : gen_norams

    prim_ram_1p_pkg::ram_1p_cfg_t unused_ram_cfg;
    logic unused_ram_inputs;

    assign unused_ram_cfg    = ram_cfg_i;
    assign unused_ram_inputs = (|NumAddrScrRounds);

  end

  // Redundant lockstep core implementation
  if (Lockstep) begin : gen_lockstep
    // SEC_CM: LOGIC.SHADOW
    // Note: certain synthesis tools like DC are very smart at optimizing away redundant logic.
    // Hence, we have to insert an optimization barrier at the IOs of the lockstep Ibex.
    // This is achieved by manually buffering each bit using prim_buf.
    // Our Xilinx and DC synthesis flows make sure that these buffers cannot be optimized away
    // using keep attributes (Vivado) and size_only constraints (DC).

    localparam int NumBufferBits = $bits({
      hart_id_i,
      boot_addr_i,
      instr_req_o,
      instr_gnt_i,
      instr_rvalid_i,
      instr_addr_o,
      instr_rdata_i,
      instr_rdata_intg_i,
      instr_err_i,
      data_req_o,
      data_gnt_i,
      data_rvalid_i,
      data_we_o,
      data_be_o,
      data_addr_o,
      data_wdata_o,
      data_rdata_i,
      data_rdata_intg_i,
      data_err_i,
      dummy_instr_id,
      rf_raddr_a,
      rf_raddr_b,
      rf_waddr_wb,
      rf_we_wb,
      rf_wdata_wb_ecc,
      rf_rdata_a_ecc,
      rf_rdata_b_ecc,
      irq_software_i,
      irq_timer_i,
      irq_external_i,
      irq_fast_i,
      irq_nm_i,
      irq_pending,
      debug_req_i,
      crash_dump_o,
      double_fault_seen_o,
      fetch_enable_i,
      core_busy_d
    });

    logic [NumBufferBits-1:0] buf_in, buf_out;

    logic [31:0]                  hart_id_local;
    logic [31:0]                  boot_addr_local;

    logic                         instr_req_local;
    logic                         instr_gnt_local;
    logic                         instr_rvalid_local;
    logic [31:0]                  instr_addr_local;
    logic [31:0]                  instr_rdata_local;
    logic [6:0]                   instr_rdata_intg_local;
    logic                         instr_err_local;

    logic                         data_req_local;
    logic                         data_gnt_local;
    logic                         data_rvalid_local;
    logic                         data_we_local;
    logic [3:0]                   data_be_local;
    logic [31:0]                  data_addr_local;
    logic [31:0]                  data_wdata_local;
    logic [6:0]                   data_wdata_intg_local;
    logic [31:0]                  data_rdata_local;
    logic [6:0]                   data_rdata_intg_local;
    logic                         data_err_local;

    logic                         dummy_instr_id_local;
    logic [4:0]                   rf_raddr_a_local;
    logic [4:0]                   rf_raddr_b_local;
    logic [4:0]                   rf_waddr_wb_local;
    logic                         rf_we_wb_local;
    logic [31:0]  rf_wdata_wb_ecc_local;
    logic [31:0]  rf_rdata_a_ecc_local;
    logic [31:0]  rf_rdata_b_ecc_local;

    logic                         irq_software_local;
    logic                         irq_timer_local;
    logic                         irq_external_local;
    logic [14:0]                  irq_fast_local;
    logic                         irq_nm_local;
    logic                         irq_pending_local;

    logic                         debug_req_local;
    crash_dump_t                  crash_dump_local;
    logic                         double_fault_seen_local;
    fetch_enable_t                fetch_enable_local;

    logic                         core_busy_local;

    assign buf_in = {
      hart_id_i,
      boot_addr_i,
      instr_req_o,
      instr_gnt_i,
      instr_rvalid_i,
      instr_addr_o,
      instr_rdata_i,
      instr_rdata_intg_i,
      instr_err_i,
      data_req_o,
      data_gnt_i,
      data_rvalid_i,
      data_we_o,
      data_be_o,
      data_addr_o,
      data_wdata_o,
      data_rdata_i,
      data_rdata_intg_i,
      data_err_i,
      dummy_instr_id,
      rf_raddr_a,
      rf_raddr_b,
      rf_waddr_wb,
      rf_we_wb,
      rf_wdata_wb_ecc,
      rf_rdata_a_ecc,
      rf_rdata_b_ecc,
      irq_software_i,
      irq_timer_i,
      irq_external_i,
      irq_fast_i,
      irq_nm_i,
      irq_pending,
      debug_req_i,
      crash_dump_o,
      double_fault_seen_o,
      fetch_enable_i,
      core_busy_d
    };

    assign {
      hart_id_local,
      boot_addr_local,
      instr_req_local,
      instr_gnt_local,
      instr_rvalid_local,
      instr_addr_local,
      instr_rdata_local,
      instr_rdata_intg_local,
      instr_err_local,
      data_req_local,
      data_gnt_local,
      data_rvalid_local,
      data_we_local,
      data_be_local,
      data_addr_local,
      data_wdata_local,
      data_rdata_local,
      data_rdata_intg_local,
      data_err_local,
      dummy_instr_id_local,
      rf_raddr_a_local,
      rf_raddr_b_local,
      rf_waddr_wb_local,
      rf_we_wb_local,
      rf_wdata_wb_ecc_local,
      rf_rdata_a_ecc_local,
      rf_rdata_b_ecc_local,
      irq_software_local,
      irq_timer_local,
      irq_external_local,
      irq_fast_local,
      irq_nm_local,
      irq_pending_local,
      debug_req_local,
      crash_dump_local,
      double_fault_seen_local,
      fetch_enable_local,
      core_busy_local
    } = buf_out;

    // Manually buffer all input signals.
    prim_buf #(.Width(NumBufferBits)) u_signals_prim_buf (
      .in_i(buf_in),
      .out_o(buf_out)
    );

    logic lockstep_alert_minor_local, lockstep_alert_major_internal_local;
    logic lockstep_alert_major_bus_local;

    cve2_lockstep #(
      .PMPEnable        (PMPEnable),
      .PMPGranularity   (PMPGranularity),
      .PMPNumRegions    (PMPNumRegions),
      .MHPMCounterNum   (MHPMCounterNum),
      .MHPMCounterWidth (MHPMCounterWidth),
      .RV32E            (RV32E),
      .RV32M            (RV32M),
      .RV32B            (RV32B),
      .BranchPredictor  (BranchPredictor),
      .DbgTriggerEn     (DbgTriggerEn),
      .DbgHwBreakNum    (DbgHwBreakNum),
      .WritebackStage   (WritebackStage),
      .DmHaltAddr       (DmHaltAddr),
      .DmExceptionAddr  (DmExceptionAddr)
    ) u_cve2_lockstep (
      .clk_i                  (clk),
      .rst_ni                 (rst_ni),

      .hart_id_i              (hart_id_local),
      .boot_addr_i            (boot_addr_local),

      .instr_req_i            (instr_req_local),
      .instr_gnt_i            (instr_gnt_local),
      .instr_rvalid_i         (instr_rvalid_local),
      .instr_addr_i           (instr_addr_local),
      .instr_rdata_i          (instr_rdata_local),
      .instr_rdata_intg_i     (instr_rdata_intg_local),
      .instr_err_i            (instr_err_local),

      .data_req_i             (data_req_local),
      .data_gnt_i             (data_gnt_local),
      .data_rvalid_i          (data_rvalid_local),
      .data_we_i              (data_we_local),
      .data_be_i              (data_be_local),
      .data_addr_i            (data_addr_local),
      .data_wdata_i           (data_wdata_local),
      .data_wdata_intg_o      (data_wdata_intg_local),
      .data_rdata_i           (data_rdata_local),
      .data_rdata_intg_i      (data_rdata_intg_local),
      .data_err_i             (data_err_local),

      .dummy_instr_id_i       (dummy_instr_id_local),
      .rf_raddr_a_i           (rf_raddr_a_local),
      .rf_raddr_b_i           (rf_raddr_b_local),
      .rf_waddr_wb_i          (rf_waddr_wb_local),
      .rf_we_wb_i             (rf_we_wb_local),
      .rf_wdata_wb_ecc_i      (rf_wdata_wb_ecc_local),
      .rf_rdata_a_ecc_i       (rf_rdata_a_ecc_local),
      .rf_rdata_b_ecc_i       (rf_rdata_b_ecc_local),

      .irq_software_i         (irq_software_local),
      .irq_timer_i            (irq_timer_local),
      .irq_external_i         (irq_external_local),
      .irq_fast_i             (irq_fast_local),
      .irq_nm_i               (irq_nm_local),
      .irq_pending_i          (irq_pending_local),

      .debug_req_i            (debug_req_local),
      .crash_dump_i           (crash_dump_local),
      .double_fault_seen_i    (double_fault_seen_local),

      .fetch_enable_i         (fetch_enable_local),
      .alert_minor_o          (lockstep_alert_minor_local),
      .alert_major_internal_o (lockstep_alert_major_internal_local),
      .alert_major_bus_o      (lockstep_alert_major_bus_local),
      .core_busy_i            (core_busy_local),
      .test_en_i              (test_en_i),
      .scan_rst_ni            (scan_rst_ni)
    );

    // Manually buffer the output signals.
    prim_buf #(.Width (7)) u_prim_buf_wdata_intg (
      .in_i(data_wdata_intg_local),
      .out_o(data_wdata_intg_o)
    );

    prim_buf u_prim_buf_alert_minor (
      .in_i (lockstep_alert_minor_local),
      .out_o(lockstep_alert_minor)
    );

    prim_buf u_prim_buf_alert_major_internal (
      .in_i (lockstep_alert_major_internal_local),
      .out_o(lockstep_alert_major_internal)
    );

    prim_buf u_prim_buf_alert_major_bus (
      .in_i (lockstep_alert_major_bus_local),
      .out_o(lockstep_alert_major_bus)
    );

  end else begin : gen_no_lockstep
    assign lockstep_alert_major_internal = 1'b0;
    assign lockstep_alert_major_bus      = 1'b0;
    assign lockstep_alert_minor          = 1'b0;
    assign data_wdata_intg_o             = 'b0;
    logic unused_scan, unused_intg;
    assign unused_scan = scan_rst_ni;
    assign unused_intg = |{instr_rdata_intg_i, data_rdata_intg_i};
  end

  assign alert_major_internal_o = core_alert_major | lockstep_alert_major_internal;
  assign alert_major_bus_o      = lockstep_alert_major_bus;
  assign alert_minor_o          = core_alert_minor | lockstep_alert_minor;

  // X checks for top-level outputs
  `ASSERT_KNOWN(IbexInstrReqX, instr_req_o)
  `ASSERT_KNOWN_IF(IbexInstrReqPayloadX, instr_addr_o, instr_req_o)

  `ASSERT_KNOWN(IbexDataReqX, data_req_o)
  `ASSERT_KNOWN_IF(IbexDataReqPayloadX,
    {data_we_o, data_be_o, data_addr_o, data_wdata_o, data_wdata_intg_o}, data_req_o)

  `ASSERT_KNOWN(IbexDoubleFaultSeenX, double_fault_seen_o)
  `ASSERT_KNOWN(IbexAlertMinorX, alert_minor_o)
  `ASSERT_KNOWN(IbexAlertMajorInternalX, alert_major_internal_o)
  `ASSERT_KNOWN(IbexAlertMajorBusX, alert_major_bus_o)
  `ASSERT_KNOWN(IbexCoreSleepX, core_sleep_o)

  // X check for top-level inputs
  `ASSERT_KNOWN(IbexTestEnX, test_en_i)
  `ASSERT_KNOWN(IbexRamCfgX, ram_cfg_i)
  `ASSERT_KNOWN(IbexHartIdX, hart_id_i)
  `ASSERT_KNOWN(IbexBootAddrX, boot_addr_i)

  `ASSERT_KNOWN(IbexInstrGntX, instr_gnt_i)
  `ASSERT_KNOWN(IbexInstrRValidX, instr_rvalid_i)
  `ASSERT_KNOWN_IF(IbexInstrRPayloadX,
    {instr_rdata_i, instr_rdata_intg_i, instr_err_i}, instr_rvalid_i)

  `ASSERT_KNOWN(IbexDataGntX, data_gnt_i)
  `ASSERT_KNOWN(IbexDataRValidX, data_rvalid_i)
  `ASSERT_KNOWN_IF(IbexDataRPayloadX, {data_rdata_i, data_rdata_intg_i, data_err_i}, data_rvalid_i)

  `ASSERT_KNOWN(IbexIrqX, {irq_software_i, irq_timer_i, irq_external_i, irq_fast_i, irq_nm_i})

  `ASSERT_KNOWN(IbexDebugReqX, debug_req_i)
  `ASSERT_KNOWN(IbexFetchEnableX, fetch_enable_i)
endmodule
