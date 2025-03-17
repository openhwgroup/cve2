.. _debug-support:

Debug Support
=============

CVE2 offers support for execution-based debug according to the `RISC-V Debug Specification <https://riscv.org/specifications/debug-specification/>`_, version 0.13.


.. note::

   Debug support in CVE2 is only one of the components needed to build a System on Chip design with run-control debug support (think "the ability to attach GDB to a core over JTAG").
   Additionally, a Debug Module and a Debug Transport Module, compliant with the RISC-V Debug Specification, are needed.

   A supported open source implementation of these building blocks can be found in the `RISC-V Debug Support for PULP Cores IP block <https://github.com/pulp-platform/riscv-dbg/>`_.

   The `OpenTitan project <https://github.com/lowRISC/opentitan>`_ can serve as an example of how to integrate the two components in a toplevel design.

Interface
---------

+----------------------------------+---------------------+--------------------------------------------------------------------------------------+
| Signal                           | Direction           | Description                                                                          |
+==================================+=====================+======================================================================================+
| ``debug_req_i``                  | input               | Request to enter Debug Mode                                                          |
+----------------------------------+---------------------+--------------------------------------------------------------------------------------+
| ``debug_halted_o``               | output              | Asserted if core enters Debug Mode                                                   |
+----------------------------------+---------------------+--------------------------------------------------------------------------------------+
| ``dm_halt_addr_i``               | input               | Address to jump to when entering Debug Mode (default 0x1A110800)                     |
+----------------------------------+---------------------+--------------------------------------------------------------------------------------+
| ``dm_exception_addr_i``          | input               | Address to jump to when an exception occurs while in Debug Mode (default 0x1A110808) |
+----------------------------------+---------------------+--------------------------------------------------------------------------------------+

``debug_req_i`` is the "debug interrupt", issued by the debug module when the core should enter Debug Mode.

Core Debug Registers
--------------------

CVE2 implements four core debug registers, namely :ref:`csr-dcsr`, :ref:`csr-dpc`, and two debug scratch registers.
Debug trigger registers are available. See :ref:`csr-tselect`, :ref:`csr-tdata1` and :ref:`csr-tdata2` for details.
All those registers are accessible from Debug Mode only.
If software tries to access them without the core being in Debug Mode, an illegal instruction exception is triggered.
