CV32E20: An embedded 32-bit RISC-V CPU core
===========================================

CV32E20 is a production-quality open source 32-bit RISC-V CPU core written in SystemVerilog.
The CPU core is based on the Ibex core, but simplified and verified under the OpenHW Group.

You are now reading the CV32E20 documentation.
The documentation is split into multiple parts.

The :doc:`Technical Specification <01_specification/index>` contains the technical specification of CV32E20.
It defines the supported features in the form of requirements.

The remaining parts of documentation are inherited from the Ibex project. They are kept for reference and will be reworked in the future.

The :doc:`User Guide <02_user/index>` provides all necessary information to use Ibex.
It is aimed at hardware developers integrating Ibex into a design, and software developers writing software running on Ibex.

The :doc:`Reference Guide <03_reference/index>` provides background information.
It describes the design in detail, discusses the verification approach and the resulting testbench structures, and generally helps to understand Ibex in depth.

.. toctree::
   :maxdepth: 3
   :hidden:

   01_specification/index.rst
   02_user/index.rst
   03_reference/index.rst
