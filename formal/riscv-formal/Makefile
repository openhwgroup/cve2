# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Provide a convenient way to create a Verilog source of Ibex.
# This is used by riscv-formal. See README.md for more details.

# Name of the output file
IBEX_OUT := ibex.v
# Build folder name
OUTDIR   := build

# Source directory relative to this Makefile
SRC_DIR  := ../../rtl

# Synthesis source directory relative to this Makefile
SYN_DIR  := ../../syn

# Vendored IP directory relative to this Makefile
LOWRISC_IP := ../../vendor/lowrisc_ip

# Include directories relative to this Makefile
INC_DIRS :=                    \
  $(LOWRISC_IP)/ip/prim/rtl    \
  $(LOWRISC_IP)/dv/sv/dv_utils

# SystemVerilog sources of Ibex
SRCS_SV ?=                              \
  $(SRC_DIR)/cve2_alu.sv                \
  $(SRC_DIR)/cve2_compressed_decoder.sv \
  $(SRC_DIR)/cve2_controller.sv         \
  $(SRC_DIR)/cve2_counter.sv            \
  $(SRC_DIR)/cve2_csr.sv                \
  $(SRC_DIR)/cve2_cs_registers.sv       \
  $(SRC_DIR)/cve2_decoder.sv            \
  $(SRC_DIR)/cve2_ex_block.sv           \
  $(SRC_DIR)/cve2_fetch_fifo.sv         \
  $(SRC_DIR)/cve2_id_stage.sv           \
  $(SRC_DIR)/cve2_if_stage.sv           \
  $(SRC_DIR)/cve2_load_store_unit.sv    \
  $(SRC_DIR)/cve2_multdiv_fast.sv       \
  $(SRC_DIR)/cve2_multdiv_slow.sv       \
  $(SRC_DIR)/cve2_prefetch_buffer.sv    \
  $(SRC_DIR)/cve2_pmp.sv                \
  $(SRC_DIR)/cve2_register_file_ff.sv   \
  $(SRC_DIR)/cve2_wb.sv                 \
  $(SRC_DIR)/cve2_core.sv               \
  $(SRC_DIR)/cve2_top.sv

PKGS ?=                                        \
  $(SRC_DIR)/cve2_pkg.sv                       \
  $(LOWRISC_IP)/ip/prim/rtl/prim_ram_1p_pkg.sv

PRIM_CLOCK ?= $(SYN_DIR)/rtl/prim_clock_gating.v

GEN_V := $(patsubst %.sv,%.v,$(patsubst $(SRC_DIR)%,$(OUTDIR)%,$(SRCS_SV)))

all: $(IBEX_OUT)

verilog: $(GEN_V)

$(OUTDIR):
	mkdir -p $(OUTDIR)

# Convert each SystemVerilog source into a Verilog file
$(GEN_V): $(OUTDIR)%.v: $(SRC_DIR)%.sv $(PKGS) | $(OUTDIR)
	sv2v --define=RISCV_FORMAL $(addprefix -I,$(INC_DIRS)) $(PKGS) \
		$< > $@

# Combine multiple Verilog sources into one Ibex Verilog file
# Disable "M" extension
$(IBEX_OUT): $(GEN_V) $(PRIM_CLOCK)
	yosys -p "read_verilog $(PRIM_CLOCK) $(GEN_V)"                     \
	      -p "chparam -set RV32M 0 cve2_top"                           \
	      -p "synth -top cve2_top"                                     \
	      -p "write_verilog $(IBEX_OUT)"

.PHONY: clean
clean:
	-rm -rf $(IBEX_OUT) $(OUTDIR)
