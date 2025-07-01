CV32E20: An embedded 32-bit RISC-V CPU core
===========================================

CV32E20 is a specific configuration of the CVE2 and is a production-quality open source 32-bit RISC-V CPU core written in SystemVerilog.
The CVE2 is based on the lowRISC Ibex core, but simplified and (re) verified by the OpenHW Foundation.

You are now reading the CV32E20 documentation.
The documentation is split into multiple parts.

The :doc:`Technical Specification <01_specification/index>` contains the technical specification of CV32E20.
It defines the supported features in the form of requirements.

The remaining parts of documentation are inherited from the CVE2 project. They are kept for reference and will be reworked in the future.

The :doc:`User Guide <02_user/index>` provides all necessary information to use CVE2.
It is aimed at hardware developers integrating CVE2 into a design, and software developers writing software running on CVE2.

The :doc:`Reference Guide <03_reference/index>` provides background information.
It describes the design in detail, discusses the verification approach and the resulting testbench structures, and generally helps to understand CVE2 in depth.

.. toctree::
   :maxdepth: 3
   :hidden:

   01_specification/index.rst
   02_user/index.rst
   03_reference/index.rst
