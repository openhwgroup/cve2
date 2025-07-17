.. _cs-registers:

Control and Status Registers
============================

CVE2 implements all the Control and Status Registers (CSRs) listed in the following table according to the RISC-V Privileged Specification, version 1.11.

+---------+--------------------+--------+-----------------------------------------------+
| Address |   Name             | Access | Description                                   |
+=========+====================+========+===============================================+
|  0x300  | ``mstatus``        | WARL   | Machine Status                                |
+---------+--------------------+--------+-----------------------------------------------+
|  0x301  | ``misa``           | WARL   | Machine ISA and Extensions                    |
+---------+--------------------+--------+-----------------------------------------------+
|  0x304  | ``mie``            | WARL   | Machine Interrupt Enable Register             |
+---------+--------------------+--------+-----------------------------------------------+
|  0x305  | ``mtvec``          | WARL   | Machine Trap-Vector Base Address              |
+---------+--------------------+--------+-----------------------------------------------+
|  0x320  | ``mcountinhibit``  | RW     | Machine Counter-Inhibit Register              |
+---------+--------------------+--------+-----------------------------------------------+
|  0x323  | ``mhpmevent3``     | WARL   | Machine Performance-Monitoring Event Selector |
+---------+--------------------+--------+-----------------------------------------------+
|     .             .               .                    .                              |
+---------+--------------------+--------+-----------------------------------------------+
|  0x33F  | ``mhpmevent31``    | WARL   | Machine Performance-Monitoring Event Selector |
+---------+--------------------+--------+-----------------------------------------------+
|  0x340  | ``mscratch``       | RW     | Machine Scratch Register                      |
+---------+--------------------+--------+-----------------------------------------------+
|  0x341  | ``mepc``           | WARL   | Machine Exception Program Counter             |
+---------+--------------------+--------+-----------------------------------------------+
|  0x342  | ``mcause``         | WLRL   | Machine Cause Register                        |
+---------+--------------------+--------+-----------------------------------------------+
|  0x343  | ``mtval``          | WARL   | Machine Trap Value Register                   |
+---------+--------------------+--------+-----------------------------------------------+
|  0x344  | ``mip``            | R      | Machine Interrupt Pending Register            |
+---------+--------------------+--------+-----------------------------------------------+
|  0x3A0  | ``pmpcfg0``        | WARL   | PMP Configuration Register                    |
+---------+--------------------+--------+-----------------------------------------------+
|     .             .               .                    .                              |
+---------+--------------------+--------+-----------------------------------------------+
|  0x3A3  | ``pmpcfg3``        | WARL   | PMP Configuration Register                    |
+---------+--------------------+--------+-----------------------------------------------+
|  0x3B0  | ``pmpaddr0``       | WARL   | PMP Address Register                          |
+---------+--------------------+--------+-----------------------------------------------+
|     .             .               .                    .                              |
+---------+--------------------+--------+-----------------------------------------------+
|  0x3BF  | ``pmpaddr15``      | WARL   | PMP Address Register                          |
+---------+--------------------+--------+-----------------------------------------------+
|     .             .               .                    .                              |
+---------+--------------------+--------+-----------------------------------------------+
|  0x757  | ``mseccfgh``       | WARL   | Upper 32 bits of ``mseccfg``                  |
+---------+--------------------+--------+-----------------------------------------------+
|  0x7A0  | ``tselect``        | WARL   | Trigger Select Register                       |
+---------+--------------------+--------+-----------------------------------------------+
|  0x7A1  | ``tdata1``         | WARL   | Trigger Data Register 1                       |
+---------+--------------------+--------+-----------------------------------------------+
|  0x7A2  | ``tdata2``         | WARL   | Trigger Data Register 2                       |
+---------+--------------------+--------+-----------------------------------------------+
|  0x7A3  | ``tdata3``         | WARL   | Trigger Data Register 3                       |
+---------+--------------------+--------+-----------------------------------------------+
|  0x7A8  | ``mcontext``       | WARL   | Machine Context Register                      |
+---------+--------------------+--------+-----------------------------------------------+
|  0x7AA  | ``scontext``       | WARL   | Supervisor Context Register                   |
+---------+--------------------+--------+-----------------------------------------------+
|  0x7B0  | ``dcsr``           | WARL   | Debug Control and Status Register             |
+---------+--------------------+--------+-----------------------------------------------+
|  0x7B1  | ``dpc``            | RW     | Debug PC                                      |
+---------+--------------------+--------+-----------------------------------------------+
|  0x7B2  | ``dscratch0``      | RW     | Debug Scratch Register 0                      |
+---------+--------------------+--------+-----------------------------------------------+
|  0x7B3  | ``dscratch1``      | RW     | Debug Scratch Register 1                      |
+---------+--------------------+--------+-----------------------------------------------+
|  0x7C0  | ``cpuctrl``        | WARL   | CPU Control Register (Custom CSR)             |
+---------+--------------------+--------+-----------------------------------------------+
|     .             .               .                    .                              |
+---------+--------------------+--------+-----------------------------------------------+
|  0xB00  | ``mcycle``         | RW     | Machine Cycle Counter                         |
+---------+--------------------+--------+-----------------------------------------------+
|  0xB02  | ``minstret``       | RW     | Machine Instructions-Retired Counter          |
+---------+--------------------+--------+-----------------------------------------------+
|  0xB03  | ``mhpmcounter3``   | WARL   | Machine Performance-Monitoring Counter        |
+---------+--------------------+--------+-----------------------------------------------+
|     .             .               .                    .                              |
+---------+--------------------+--------+-----------------------------------------------+
|  0xB1F  | ``mhpmcounter31``  | WARL   | Machine Performance-Monitoring Counter        |
+---------+--------------------+--------+-----------------------------------------------+
|  0xB80  | ``mcycleh``        | RW     | Upper 32 bits of ``mcycle``                   |
+---------+--------------------+--------+-----------------------------------------------+
|  0xB82  | ``minstreth``      | RW     | Upper 32 bits of ``minstret``                 |
+---------+--------------------+--------+-----------------------------------------------+
|  0xB83  | ``mhpmcounter3h``  | WARL   | Upper 32 bits of ``mhmpcounter3``             |
+---------+--------------------+--------+-----------------------------------------------+
|     .             .               .                    .                              |
+---------+--------------------+--------+-----------------------------------------------+
|  0xB9F  | ``mhpmcounter31h`` | WARL   | Upper 32 bits of ``mhmpcounter31``            |
+---------+--------------------+--------+-----------------------------------------------+
|  0xF11  | ``mvendorid``      | R      | Machine Vendor ID                             |
+---------+--------------------+--------+-----------------------------------------------+
|  0xF12  | ``marchid``        | R      | Machine Architecture ID                       |
+---------+--------------------+--------+-----------------------------------------------+
|  0xF13  | ``mimpid``         | R      | Machine Implementation ID                     |
+---------+--------------------+--------+-----------------------------------------------+
|  0xF14  | ``mhartid``        | R      | Hardware Thread ID                            |
+---------+--------------------+--------+-----------------------------------------------+

See the :ref:`performance-counters` documentation for a description of the counter registers.


Machine Status (mstatus)
------------------------

CSR Address: ``0x300``

Reset Value: ``0x0000_1800``

+-------+-----+---------------------------------------------------------------------------------+
| Bit#  | R/W | Description                                                                     |
+-------+-----+---------------------------------------------------------------------------------+
| 21    | RW  | **TW:** Timeout Wait (WFI executed in User Mode will trap to Machine Mode).     |
+-------+-----+---------------------------------------------------------------------------------+
| 17    | RW  | **MPRV:** Modify Privilege (Loads and stores use MPP for privilege checking).   |
+-------+-----+---------------------------------------------------------------------------------+
| 12:11 | RW  | **MPP:** Machine Previous Privilege mode.                                       |
+-------+-----+---------------------------------------------------------------------------------+
| 7     | RW  | **Previous Interrupt Enable (MPIE)**, i.e., before entering exception handling. |
+-------+-----+---------------------------------------------------------------------------------+
| 3     | RW  | **Interrupt Enable (MIE):** If set to 1'b1, interrupts are globally enabled.    |
+-------+-----+---------------------------------------------------------------------------------+

When an exception is encountered, ``mstatus``.MPIE will be set to ``mstatus``.MIE, and ``mstatus``.MPP will be set to the current privilege mode.
When the MRET instruction is executed, the value of MPIE will be stored back to ``mstatus``.MIE, and the privilege mode will be restored from ``mstatus``.MPP.

If you want to enable interrupt handling in your exception handler, set ``mstatus``.MIE to 1'b1 inside your handler code.

Only Machine Mode and User Mode are supported.
Any write to ``mstatus``.MPP of an unsupported value will be interpreted as Machine Mode.

Machine ISA Register (misa)
---------------------------

CSR Address: ``0x301``

Reset Value: ``0x4010_1104``

``misa`` is a WARL register which describes the ISA supported by the hart.
On CVE2, ``misa`` is hard-wired, i.e. it will remain unchanged after any write.

Detailed:

+-------------+------------+------------------------------------------------------------------------+
| **Bit #**   | **Mode**   | **Description**                                                        |
+=============+============+========================================================================+
| 31:30       | RO  (0x01) | **MXL** (Machine XLEN)                                                 |
+-------------+------------+------------------------------------------------------------------------+
| 29:26       | RO   (0x0) | (Reserved)                                                             |
+-------------+------------+------------------------------------------------------------------------+
| 25          | RO   (0x0) | **Z** (Reserved)                                                       |
+-------------+------------+------------------------------------------------------------------------+
| 24          | RO   (0x0) | **Y** (Reserved)                                                       |
+-------------+------------+------------------------------------------------------------------------+
| 23          | RO   (0x0) | **X** (Non-standard extensions present)                                |
+-------------+------------+------------------------------------------------------------------------+
| 22          | RO   (0x0) | **W** (Reserved)                                                       |
+-------------+------------+------------------------------------------------------------------------+
| 21          | RO   (0x0) | **V** (Tentatively reserved for Vector extension)                      |
+-------------+------------+------------------------------------------------------------------------+
| 20          | RO   (0x1) | **U** (User mode implemented)                                          |
+-------------+------------+------------------------------------------------------------------------+
| 19          | RO   (0x0) | **T** (Tentatively reserved for Transactional Memory extension)        |
+-------------+------------+------------------------------------------------------------------------+
| 18          | RO   (0x0) | **S** (Supervisor mode implemented)                                    |
+-------------+------------+------------------------------------------------------------------------+
| 17          | RO   (0x0) | **R** (Reserved)                                                       |
+-------------+------------+------------------------------------------------------------------------+
| 16          | RO   (0x0) | **Q** (Quad-precision floating-point extension)                        |
+-------------+------------+------------------------------------------------------------------------+
| 15          | RO   (0x0) | **P** (Tentatively reserved for Packed-SIMD extension)                 |
+-------------+------------+------------------------------------------------------------------------+
| 14          | RO   (0x0) | **O** (Reserved)                                                       |
+-------------+------------+------------------------------------------------------------------------+
| 13          | RO   (0x0) | **N** (User-level interrupts supported)                                |
+-------------+------------+------------------------------------------------------------------------+
| 12          | RO RV32MEn | **M** (Integer Multiply/Divide extension)                              |
+-------------+------------+------------------------------------------------------------------------+
| 11          | RO   (0x0) | **L** (Tentatively reserved for Decimal Floating-Point extension)      |
+-------------+------------+------------------------------------------------------------------------+
| 10          | RO   (0x0) | **K** (Reserved)                                                       |
+-------------+------------+------------------------------------------------------------------------+
| 9           | RO   (0x0) | **J** (Tentatively reserved for Dynamically Translated Languages       |
|             |            | extension)                                                             |
+-------------+------------+------------------------------------------------------------------------+
| 8           | RO   (0x1) | **I** (RV32I/64I/128I base ISA)                                        |
+-------------+------------+------------------------------------------------------------------------+
| 7           | RO   (0x0) | **H** (Reserved)                                          		    |
+-------------+------------+------------------------------------------------------------------------+
| 6           | RO   (0x0) | **G** (Additional standard extensions present)                         |
+-------------+------------+------------------------------------------------------------------------+
| 5           | RO   (0x0) | **F** (Single-precision floating-point extension)                      |
+-------------+------------+------------------------------------------------------------------------+
| 4           | RO   RV32E | **E** (RV32E base ISA)                                                 |
+-------------+------------+------------------------------------------------------------------------+
| 3           | RO   (0x0) | **D** (Double-precision floating-point extension)                      |
+-------------+------------+------------------------------------------------------------------------+
| 2           | RO   (0x1) | **C** (Compressed extension)                                           |
+-------------+------------+------------------------------------------------------------------------+
| 1           | RO RV32BEn | **B** (Tentatively reserved for Bit-Manipulation extension)            |
+-------------+------------+------------------------------------------------------------------------+
| 0           | RO   (0x0) | **A** (Atomic extension)                                               |
+-------------+------------+------------------------------------------------------------------------+

* **M** = 0 if RV32M == RV32MNone and 1 otherwise, It's controlled by "RV32MEnabled" parameter
* **MXL** = 1 (i.e. XLEN = 32)

Machine Interrupt Enable Register (mie)
---------------------------------------

CSR Address: ``0x304``

Reset Value: ``0x0000_0000``

``mie`` is a WARL register which allows to individually enable/disable local interrupts.
After reset, all interrupts are disabled.

+-------+--------------------------------------------------------------------------------------+
| Bit#  | Interrupt                                                                            |
+-------+--------------------------------------------------------------------------------------+
| 30:16 | Machine Fast Interrupt Enables: Set bit x+16 to enable                               |
|       | fast interrupt ``irq_fast_i[x]``.                                                    |
+-------+--------------------------------------------------------------------------------------+
| 11    | **Machine External Interrupt Enable (MEIE):** If set, ``irq_external_i`` is enabled. |
+-------+--------------------------------------------------------------------------------------+
| 7     | **Machine Timer Interrupt Enable (MTIE):** If set, ``irq_timer_i`` is enabled.       |
+-------+--------------------------------------------------------------------------------------+
| 3     | **Machine Software Interrupt Enable (MSIE):** if set, ``irq_software_i`` is enabled. |
+-------+--------------------------------------------------------------------------------------+


Machine Trap-Vector Base Address (mtvec)
----------------------------------------

CSR Address: ``0x305``

Reset Value: ``0x0000_0001``

``mtvec`` is a WARL register which contains the machine trap-vector base address.

+-------+--------------------------------------------------------------------------------------+
| Bit#  | Interrupt                                                                            |
+-------+--------------------------------------------------------------------------------------+
| 31:2  | **BASE:** The trap-vector base address, always aligned to 256 bytes, i.e.,           |
|       | ``mtvec[7:2]`` is always set to 6'b0.                                                |
+-------+--------------------------------------------------------------------------------------+
| 1:0   | **MODE:** Always set to 2'b01 to indicate vectored interrupt handling (read-only).   |
+-------+--------------------------------------------------------------------------------------+


Machine Exception PC (mepc)
---------------------------

CSR Address: ``0x341``

Reset Value: ``0x0000_0000``

When an exception is encountered, the current program counter is saved in ``mepc``, and the core jumps to the exception address.
When an MRET instruction is executed, the value from ``mepc`` replaces the current program counter.


Machine Cause (mcause)
----------------------

CSR Address: ``0x342``

Reset Value: ``0x0000_0000``

+-------+-----+------------------------------------------------------------------+
| Bit#  | R/W | Description                                                      |
+-------+-----+------------------------------------------------------------------+
| 31    | R   | **Interrupt:** This bit is set when the exception was triggered  |
|       |     | by an interrupt.                                                 |
+-------+-----+------------------------------------------------------------------+
| 4:0   | R   | **Exception Code**                                               |
+-------+-----+------------------------------------------------------------------+

When an exception is encountered, the corresponding exception code is stored in this register.


Machine Trap Value (mtval)
--------------------------

CSR Address: ``0x343``

Reset Value: ``0x0000_0000``

When an exception is encountered, this register can hold exception-specific information to assist software in handling the trap.

 * In the case of errors in the load-store unit ``mtval`` holds the address of the transaction causing the error.
 * If this transaction is misaligned, ``mtval`` holds the address of the missing transaction part.
 * In the case of illegal instruction exceptions, ``mtval`` holds the actual faulting instruction.

For all other exceptions, ``mtval`` is 0.


Machine Interrupt Pending Register (mip)
----------------------------------------

CSR Address: ``0x344``

Reset Value: ``0x0000_0000``

``mip`` is a read-only register indicating pending interrupt requests.
A particular bit in the register reads as one if the corresponding interrupt input signal is high and if the interrupt is enabled in the ``mie`` CSR.

+-------+---------------------------------------------------------------------------------------+
| Bit#  | Interrupt                                                                             |
+-------+---------------------------------------------------------------------------------------+
| 30:16 | Machine Fast Interrupts Pending: If bit x+16 is set,                                  |
|       | fast interrupt ``irq_fast_i[x]`` is pending.                                          |
+-------+---------------------------------------------------------------------------------------+
| 11    | **Machine External Interrupt Pending (MEIP):** If set, ``irq_external_i`` is pending. |
+-------+---------------------------------------------------------------------------------------+
| 7     | **Machine Timer Interrupt Pending (MTIP):** If set, ``irq_timer_i`` is pending.       |
+-------+---------------------------------------------------------------------------------------+
| 3     | **Machine Software Interrupt Pending (MSIP):** if set, ``irq_software_i`` is pending. |
+-------+---------------------------------------------------------------------------------------+

PMP Configuration Register (pmpcfgx)
------------------------------------

CSR Address: ``0x3A0 - 0x3A3``

Reset Value: ``0x0000_0000``

``pmpcfgx`` are registers to configure PMP regions. Each register configures 4 PMP regions.

+---------+---------+---------+---------+
|  31:24  |  23:16  |  15:8   |   7:0   |
+---------+---------+---------+---------+
| pmp3cfg | pmp2cfg | pmp1cfg | pmp0cfg |
+---------+---------+---------+---------+

The configuration fields for each region are as follows:

+-------+--------------------------+
| Bit#  |  Definition              |
+-------+--------------------------+
|    7  | Lock                     |
+-------+--------------------------+
|  6:5  | Reserved (Read as zero)  |
+-------+--------------------------+
|  4:3  | Mode                     |
+-------+--------------------------+
|    2  | Execute permission       |
+-------+--------------------------+
|    1  | Write permission         |
+-------+--------------------------+
|    0  | Read permission          |
+-------+--------------------------+

Details of these configuration bits can be found in the RISC-V Privileged Specification, version 1.11 (see Physical Memory Protection CSRs, Section 3.6.1).

Note that the combination of Write permission = 1, Read permission = 0 is reserved, and will be treated by the core as Read/Write permission = 0.

PMP Address Register (pmpaddrx)
-------------------------------

CSR Address: ``0x3B0 - 0x3BF``

Reset Value: ``0x0000_0000``

``pmpaddrx`` are registers to set address matching for PMP regions.

+----------------+
|     31:0       |
+----------------+
| address[33:2]  |
+----------------+

.. _csr-tselect:

Trigger Select Register (tselect)
---------------------------------

CSR Address: ``0x7A0``

Reset Value: ``0x0000_0000``

Accessible in Debug Mode or M-Mode.

Number of the currently selected trigger starting at 0.
The number of triggers is 1.

Writing a value larger than or equal to the number of supported triggers will write the highest valid index.
This allows a debugger to detect the allowed number of triggers by reading back the value.

.. _csr-tdata1:

Trigger Data Register 1 (tdata1)
--------------------------------

CSR Address: ``0x7A1``

Reset Value: ``0x2800_1000``

Accessible in Debug Mode or M-Mode.
Since native triggers are not supported, writes to this register from M-Mode will be ignored.

CVE2 only implements one type of trigger, instruction address match.
Most fields of this register will read as a fixed value to reflect the mode that is supported.

+-------+------+------------------------------------------------------------------+
| Bit#  | R/W  | Description                                                      |
+-------+------+------------------------------------------------------------------+
| 31:28 | R    | **type:** 2 = Address/Data match trigger type.                   |
+-------+------+------------------------------------------------------------------+
| 27    | R    | **dmode:** 1 = Only debug mode can write tdata registers         |
+-------+------+------------------------------------------------------------------+
| 26:21 | R    | **maskmax:** 0 = Only exact matching supported.                  |
+-------+------+------------------------------------------------------------------+
| 20    | R    | **hit:** 0 = Hit indication not supported.                       |
+-------+------+------------------------------------------------------------------+
| 19    | R    | **select:** 0 = Only address matching is supported.              |
+-------+------+------------------------------------------------------------------+
| 18    | R    | **timing:** 0 = Break before the instruction at the specified    |
|       |      | address.                                                         |
+-------+------+------------------------------------------------------------------+
| 17:16 | R    | **sizelo:** 0 = Match accesses of any size.                      |
+-------+------+------------------------------------------------------------------+
| 15:12 | R    | **action:** 1 = Enter debug mode on match.                       |
+-------+------+------------------------------------------------------------------+
| 11    | R    | **chain:** 0 = Chaining not supported.                           |
+-------+------+------------------------------------------------------------------+
| 10:7  | R    | **match:** 0 = Match the whole address.                          |
+-------+------+------------------------------------------------------------------+
| 6     | R    | **m:** 1 = Match in M-Mode.                                      |
+-------+------+------------------------------------------------------------------+
| 5     | R    | zero.                                                            |
+-------+------+------------------------------------------------------------------+
| 4     | R    | **s:** 0 = S-Mode not supported.                                 |
+-------+------+------------------------------------------------------------------+
| 3     | R    | **u:** 1 = Match in U-Mode.                                      |
+-------+------+------------------------------------------------------------------+
| 2     | RW   | **execute:** Enable matching on instruction address.             |
+-------+------+------------------------------------------------------------------+
| 1     | R    | **store:** 0 = Store address / data matching not supported.      |
+-------+------+------------------------------------------------------------------+
| 0     | R    | **load:** 0 = Load address / data matching not supported.        |
+-------+------+------------------------------------------------------------------+

Details of these configuration bits can be found in the RISC-V Debug Specification, version 0.13.2 (see Trigger Registers, Section 5.2).

.. _csr-tdata2:

Trigger Data Register 2 (tdata2)
--------------------------------

CSR Address: ``0x7A2``

Reset Value: ``0x0000_0000``

Accessible in Debug Mode or M-Mode.
Since native triggers are not supported, writes to this register from M-Mode will be ignored.

This register stores the instruction address to match against for a breakpoint trigger.

Trigger Data Register 3 (tdata3)
--------------------------------

CSR Address: ``0x7A3``

Reset Value: ``0x0000_0000``

Accessible in Debug Mode or M-Mode.

CVE2 does not support the features requiring this register, so writes are ignored and it will always read as zero.

Machine Context Register (mcontext)
-----------------------------------

CSR Address: ``0x7A8``

Reset Value: ``0x0000_0000``

Accessible in Debug Mode or M-Mode.

CVE2 does not support the features requiring this register, so writes are ignored and it will always read as zero.

Supervisor Context Register (scontext)
--------------------------------------

CSR Address: ``0x7AA``

Reset Value: ``0x0000_0000``

Accessible in Debug Mode or M-Mode.

CVE2 does not support the features requiring this register, so writes are ignored and it will always read as zero.

.. _csr-dcsr:

Debug Control and Status Register (dcsr)
----------------------------------------

CSR Address: ``0x7B0``

Reset Value: ``0x4000_0003``

Accessible in Debug Mode only.
CVE2 implements the following bit fields.
Other bit fields read as zero.

+-------+------+------------------------------------------------------------------+
| Bit#  | R/W  | Description                                                      |
+-------+------+------------------------------------------------------------------+
| 31:28 | R    | **xdebugver:** 4 = External spec-compliant debug support exists. |
+-------+------+------------------------------------------------------------------+
| 15    | RW   | **ebreakm:** EBREAK in M-Mode behaves as described in Privileged |
|       |      | Spec (0), or enters Debug Mode (1).                              |
+-------+------+------------------------------------------------------------------+
| 12    | WARL | **ebreaku:** EBREAK in U-Mode behaves as described in Privileged |
|       |      | Spec (0), or enters Debug Mode (1).                              |
+-------+------+------------------------------------------------------------------+
| 8:6   | R    | **cause:** 1 = EBREAK, 2 = trigger, 3 = halt request, 4 = step   |
+-------+------+------------------------------------------------------------------+
| 2     | RW   | **step:** When set and not in Debug Mode, execute a single       |
|       |      | instruction and enter Debug Mode.                                |
+-------+------+------------------------------------------------------------------+
| 1:0   | WARL | **prv:** Privilege level the core was operating in when Debug    |
|       |      | Mode was entered. May be modified by debugger to change          |
|       |      | privilege level. CVE2 allows transitions to all supported modes. |
|       |      | (M- and U-Mode).                                                 |
+-------+------+------------------------------------------------------------------+

Details of these configuration bits can be found in the RISC-V Debug Specification, version 0.13.2 (see Core Debug Registers, Section 4.8).
Note that **ebreaku** and **prv** are accidentally specified as RW in version 0.13.2 of the RISC-V Debug Specification.
More recent versions of the specification define these fields correctly as WARL.

.. _csr-dpc:

Debug PC Register (dpc)
-----------------------

CSR Address: ``0x7B1``

Reset Value: ``0x0000_0000``

When entering Debug Mode, ``dpc`` is updated with the address of the next instruction that would be executed (if Debug Mode would not have been entered).
When resuming, the PC is set to the address stored in ``dpc``.
The debug module may modify ``dpc``.
Accessible in Debug Mode only.

Debug Scratch Register 0 (dscratch0)
------------------------------------

CSR Address: ``0x7B2``

Reset Value: ``0x0000_0000``

Scratch register to be used by the debug module.
Accessible in Debug Mode only.

Debug Scratch Register 1 (dscratch1)
------------------------------------

CSR Address: ``0x7B3``

Reset Value: ``0x0000_0000``

Scratch register to be used by the debug module.
Accessible in Debug Mode only.

CPU Control Register (cpuctrl)
------------------------------

CSR Address: ``0x7C0``

Reset Value: ``0x0000_0000``

Custom CSR to control runtime configuration of CPU components.
Accessible in Machine Mode only.
CVE2 implements the following bit fields.
Other bit fields read as zero.

+-------+------+------------------------------------------------------------------+
| Bit#  | R/W  | Description                                                      |
+-------+------+------------------------------------------------------------------+
| 7     | RW   | **double_fault_seen:** A synchronous exception was observed when |
|       |      | the ``sync_exc_seen`` field was set. This field must be manually |
|       |      | cleared, hardware only sets it (see :ref:`double-fault-detect`). |
+-------+------+------------------------------------------------------------------+
| 6     | RW   | **sync_exc_seen:** A synchronous exception has been observed.    |
|       |      | This flag is cleared when ``mret`` is executed.                  |
|       |      | (see :ref:`double-fault-detect`).                                |
+-------+------+------------------------------------------------------------------+
| 5:3   | WARL | This field will always read as zero.                             |
+-------+------+------------------------------------------------------------------+
| 2     | WARL | This field will always read as zero.                             |
+-------+------+------------------------------------------------------------------+
| 1     | WARL | This field will always read as zero.                             |
+-------+------+------------------------------------------------------------------+

Time Registers (time(h))
------------------------

CSR Address: ``0xC01 / 0xC81``

The User Mode ``time(h)`` registers are not implemented in CVE2.
Any access to these registers will trap.
It is recommended that trap handler software provides a means of accessing platform-defined ``mtime(h)`` timers where available.

Machine Vendor ID (mvendorid)
-----------------------------

CSR Address: ``0xF11``

Reset Value: ``CSR_MVENDORID_VALUE``

Use the ``CSR_MVENDORID_VALUE`` parameter in :file:`rtl/cve2_pkg.sv` to change the fixed value.
Details of what the ID represents can be found in the RISC-V Privileged Specification.

Machine Architecture ID (marchid)
---------------------------------

CSR Address: ``0xF12``

Reset Value: ``CSR_MARCHID_VALUE``

Use the ``CSR_MARCHID_VALUE`` parameter in :file:`rtl/cve2_pkg.sv` to change the fixed value.
The value used is allocated specifically to cve2. See https://github.com/riscv/riscv-isa-manual/blob/master/marchid.md.
If significant changes are made a different ID should be used.
Details of what the ID represents can be found in the RISC-V Privileged Specification.

Machine Implementation ID (mimpid)
----------------------------------

CSR Address: ``0xF13``

Reset Value: ``0x0000_0000``

Use the ``CSR_MIMPID_VALUE`` parameter in :file:`rtl/cve2_pkg.sv` to change the fixed value.
Details of what the ID represents can be found in the RISC-V Privileged Specification.

.. _csr-mhartid:

Hardware Thread ID (mhartid)
----------------------------

CSR Address: ``0xF14``

Reads directly return the value of the ``hart_id_i`` input signal.
See also :ref:`core-integration`.
