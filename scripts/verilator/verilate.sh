#!/bin/bash

VLT_CONFIG="./lint/verilator_waiver.vlt"

SV_DEPS="./vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv rtl/cve2_pkg.sv ./bhv/cve2_sim_clock_gate.sv"
SV_TOP="./rtl/cve2_top.sv"


verilator --lint-only \
          -Wall \
          -I./rtl \
          -I./vendor/lowrisc_ip/ip/prim/rtl \
          -I./vendor/lowrisc_ip/dv/sv/dv_utils \
          ${VLT_CONFIG} \
          ${SV_DEPS} \
          ${SV_TOP}
