.. _getting-started:

Getting Started with CVE2
=========================

This page discusses initial steps and requirements to start using CVE2 in your design.

Identification CSRs
-------------------

The RISC-V Privileged Architecture specifies several read-only CSRs that identify the vendor and micro-architecture of a CPU.
These are ``mvendorid``, ``marchid`` and ``mimpid``.
The fixed, read-only values for these CSRs are defined in :file:`rtl/cve2_pkg.sv`.
Implementers should carefully consider appropriate values for these registers.
CVE2, as an open source implementation, has an assigned architecture ID (``marchid``) of 0x23 (equivalent to 0d35).
(Allocations are specified in `marchid.md of the riscv-isa-manual repository <https://github.com/riscv/riscv-isa-manual/blob/master/marchid.md>`_.)
If significant changes are made to the micro-architecture a different architecture ID should be used.
The vendor ID and implementation ID (``mvendorid`` and ``mimpid``). The vendor ID (mvendorid) is assigned the value 0x602 and the implementation ID (mimpid) is assigned the value 0x0.
Please see the RISC-V Privileged Architecture specification for more details on what these IDs represent and how they should be chosen.
