.. _register-file:

Register File
=============
Source File: :file:`rtl/cve2_register_file_ff.sv`

CVE2 has either 31 or 15 32-bit registers if the RV32E extension is disabled or enabled, respectively.
Register ``x0`` is statically bound to 0 and can only be read, it does not contain any sequential logic.

The register file has two read ports and one write port, register file data is available the same cycle a read is requested.
There is no write to read forwarding path so if one register is being both read and written the read will return the current value rather than the value being written.

Flip-Flop-Based Register File
-----------------------------

The flip-flop-based register file uses regular, positive-edge-triggered flip-flops to implement the registers.

This makes it the **first choice when simulating the design using Verilator**.
