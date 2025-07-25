.. _pmp:

Physical Memory Protection (PMP)
================================

The Physical Memory Protection (PMP) unit is a `potential future design enhancement on the CVE2 <https://github.com/openhwgroup/programs/blob/master/Project-Descriptions-and-Plans/CVE20/Project-Concept-for-CV32E20.md#potential-future-design-enhancements>`_ that implements region-based memory access checking in-accordance with the RISC-V Privileged Specification, version 1.11, and includes the Trusted Execution Environment (TEE) working group proposal `PMP Enhancements for memory access and execution prevention on Machine mode (Smepmp) version 0.9.3 <https://github.com/riscv/riscv-tee/blob/61455747230a26002d741f64879dd78cc9689323/Smepmp/Smepmp.pdf>`_.
The following local parameters are available to control PMP checking:

+----------------+---------------+----------------------------------------------------------+
| localparam     | Default value | Description                                              |
+================+===============+==========================================================+
| PMPEnable      | 0             | PMP support enabled                                      |
+----------------+---------------+----------------------------------------------------------+
| PMPNumRegions  | 4             | Number of implemented regions (1 - 16)                   |
+----------------+---------------+----------------------------------------------------------+
| PMPGranularity | 0             | Minimum match granularity :math:`2^{G+2}` bytes (0 - 31) |
+----------------+---------------+----------------------------------------------------------+

When PMPEnable is zero, the PMP module is not instantiated and all PMP registers read as zero (regardless of the value of PMPNumRegions)

PMP Integration
---------------

Addresses from the instruction fetch unit and load-store unit are passed to the PMP module for checking, and the output of the PMP check is used to gate the external request.
To maintain consistency with external errors, the instruction fetch unit and load-store unit progress with their request as if it was granted externally.
The PMP error is registered and consumed by the core when the data would have been consumed.

PMP Granularity
---------------

The PMP granularity parameter is used to reduce the size of the address matching comparators by increasing the minimum region size.
When the granularity is greater than zero, NA4 mode is not available and will be treated as OFF mode.

.. _pmp-enhancements:

PMP Enhancements
----------------

These are described in more detail in `PMP Enhancements for memory access and execution prevention on Machine mode (Smepmp) version 0.9.3 <https://github.com/riscv/riscv-tee/blob/61455747230a26002d741f64879dd78cc9689323/Smepmp/Smepmp.pdf>`_.
If CVE2 is configured to include PMP (PMPEnable is not zero) the PMP enhancements are always included.
Use of the enhanced behavior is optional, if no writes to ``mseccfg`` occur PMP behavior will remain exactly as specified in the RISC-V privileged specification.
The enhancements add:

* A new CSR ``mseccfg`` providing functionality to allow locked regions to be modified and to implement default deny for M-mode accesses.
* New PMP region configurations which are U-Mode or M-Mode accessible only with varying read/write/execute settings along with some shared U and M mode accessible configurations.
  These new configurations supersede the original ones and are enabled via ``mseccfg``.

Custom Reset Values
-------------------

By default all PMP CSRs (include ``mseccfg``) are reset to 0.
Some applications may want other reset values.
Default reset values are defined in :file:`cve2_pmp_reset_default.svh`.
An implementation can either modify this file or define ``CVE2_CUSTOM_PMP_RESET_VALUES`` and place a copy of :file:`cve2_pmp_result_default.svh` in a new file, :file:`cve2_pmp_reset.svh`, changing the values as required and adding the new file to the include path of whatever build flow is being used.
