CVE2_CONFIG ?= small

FUSESOC_CONFIG_OPTS = $(shell ./util/cve2_config.py $(CVE2_CONFIG) fusesoc_opts)
FUSESOC_VERSION := $(shell fusesoc --version 2>/dev/null)
FUSESOC_REQUIRED_VERSION := 0.1


define PYTHON_REQ_INSTR
Please install the required Python packages with 
'python3 -m pip install --upgrade -r python-requirements.txt'.
Use a virtual environment if you prefer, for example:

python3 -m venv venv_cve2/
source venv_cve2/bin/activate
python3 -m pip install --upgrade -r python-requirements.txt
...
deactivate

endef

# Check if fusesoc is installed and it uses lowRISC's port
ifeq (, $(shell which fusesoc 2>/dev/null))
  $(error FuseSoC is not installed. $(PYTHON_REQ_INSTR))
endif

ifneq ($(FUSESOC_VERSION),$(FUSESOC_REQUIRED_VERSION))
  $(warning The version of FuseSoC available ($(FUSESOC_VERSION)) is probably \
    not sourced by lowRISC's ($(FUSESOC_REQUIRED_VERSION)). $(PYTHON_REQ_INSTR))
endif

all: help

.PHONY: help
help:
	@echo "This is a short hand for running popular tasks."
	@echo "Please check the documentation on how to get started"
	@echo "or how to set-up the different environments."

# Use a parallel run (make -j N) for a faster build
# build-all: build-riscv-compliance build-simple-system build-arty-100 \
#       build-csr-test
build-all: build-riscv-compliance


# RISC-V compliance
.PHONY: build-riscv-compliance
build-riscv-compliance:
	fusesoc --cores-root=. run --target=sim --setup --build \
		openhwgroup:cve2:cve2_riscv_compliance \
		$(FUSESOC_CONFIG_OPTS)


# # Simple system
# # Use the following targets:
# # - "build-simple-system"
# # - "run-simple-system"
# .PHONY: build-simple-system
# build-simple-system:
# 	fusesoc --cores-root=. run --target=sim --setup --build \
# 		openhwgroup:cve2:cve2_simple_system \
# 		$(FUSESOC_CONFIG_OPTS)

# simple-system-program = examples/sw/simple_system/hello_test/hello_test.vmem
# sw-simple-hello: $(simple-system-program)

# .PHONY: $(simple-system-program)
# $(simple-system-program):
# 	cd examples/sw/simple_system/hello_test && $(MAKE)

# Vcve2_simple_system = \
#       build/openhwgroup_cve2_cve2_simple_system_0/sim-verilator/Vcve2_simple_system
# $(Vcve2_simple_system):
# 	@echo "$@ not found"
# 	@echo "Run \"make build-simple-system\" to create the dependency"
# 	@false

# run-simple-system: sw-simple-hello | $(Vcve2_simple_system)
# 	build/openhwgroup_cve2_cve2_simple_system_0/sim-verilator/Vcve2_simple_system \
# 		--raminit=$(simple-system-program)

compile_verilator:
	fusesoc --cores-root . run --no-export --target=lint --tool=verilator --setup --build openhwgroup:cve2:cve2_top:0.1 2>&1 | tee buildsim.log

# # Arty A7 FPGA example
# # Use the following targets (depending on your hardware):
# # - "build-arty-35"
# # - "build-arty-100"
# # - "program-arty"
# arty-sw-program = examples/sw/led/led.vmem
# sw-led: $(arty-sw-program)

# .PHONY: $(arty-sw-program)
# $(arty-sw-program):
# 	cd examples/sw/led && $(MAKE)

# .PHONY: build-arty-35
# build-arty-35: sw-led
# 	fusesoc --cores-root=. run --target=synth --setup --build \
# 		openhwgroup:cve2:top_artya7 --part xc7a35ticsg324-1L

# .PHONY: build-arty-100
# build-arty-100: sw-led
# 	fusesoc --cores-root=. run --target=synth --setup --build \
# 		openhwgroup:cve2:top_artya7 --part xc7a100tcsg324-1

# .PHONY: program-arty
# program-arty:
# 	fusesoc --cores-root=. run --target=synth --run \
# 		openhwgroup:cve2:top_artya7


# Lint check
.PHONY: lint-top-tracing
lint-top-tracing:
	fusesoc --cores-root . run --target=lint openhwgroup:cve2:cve2_top_tracing \
		$(FUSESOC_CONFIG_OPTS)

# Lint check
.PHONY: lint-top
lint-top:
	fusesoc --cores-root . run --target=lint openhwgroup:cve2:cve2_top \
		$(FUSESOC_CONFIG_OPTS)


# # CS Registers testbench
# # Use the following targets:c
# # - "build-csr-test"
# # - "run-csr-test"
# .PHONY: build-csr-test
# build-csr-test:
# 	fusesoc --cores-root=. run --target=sim --setup --build \
# 	      --tool=verilator openhwgroup:cve2:tb_cs_registers
# Vtb_cs_registers = \
#       build/openhwgroup_cve2_tb_cs_registers_0/sim-verilator/Vtb_cs_registers
# $(Vtb_cs_registers):
# 	@echo "$@ not found"
# 	@echo "Run \"make build-csr-test\" to create the dependency"
# 	@false

# .PHONY: run-csr-test
# run-csr-test: | $(Vtb_cs_registers)
# 	fusesoc --cores-root=. run --target=sim --run \
# 	      --tool=verilator openhwgroup:cve2:tb_cs_registers

# Echo the parameters passed to fusesoc for the chosen CVE2_CONFIG
.PHONY: test-cfg
test-cfg:
	@echo $(FUSESOC_CONFIG_OPTS)

.PHONY: python-lint
python-lint:
	$(MAKE) -C util lint

# Sequential Equivalence Checking
.PHONY: sec
sec:
	./scripts/sec/sec.sh -t yosys

.PHONY: sec_XInterface
sec_XInterface:
	./scripts/sec/sec.sh -t yosys -X

.PHONY: clean
clean:
	-rm -rf ./build ./formal/riscv-formal/build