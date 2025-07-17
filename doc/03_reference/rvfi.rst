.. _rvfi:

RISC-V Formal Interface
=======================

CVE2 supports the `RISC-V Formal Interface (RVFI) <https://github.com/SymbioticEDA/riscv-formal/blob/master/docs/rvfi.md>`_.
This interface basically decodes the current instruction and provides additional insight into the core state thereby enabling formal verification.
Examples of such information include opcode, source and destination registers, program counter, as well as address and data for memory operations.


Formal Verification
-------------------

The signals provided by RVFI can be used to formally verify compliance of CVE2 with the `RISC-V specification <https://riscv.org/specifications/>`_.

Currently, the implementation is restricted to support the "I" and "C" extensions, and CVE2 is not yet formally verified.
It predecessor "Zero-riscy" had been tested, but this required changes to the core as well as to the tool used in the process (`yosys <https://github.com/YosysHQ/yosys>`_).
The formal verification of the CVE2 core is work in progress.
