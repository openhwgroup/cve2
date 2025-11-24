# Sequential Equivalence Checking (SEC)

This folder contains a `RTL to RTL` Sequential Equivalence Checking (SEC) script that runs with the help of
[Yosys EQY](https://yosyshq.readthedocs.io/projects/eqy/en/latest). Useful to evaluate changes on the design made during contributions or Pull Requests to the main repository branch.

> **_NOTE:_** Currently the only SEC tool officially supported by this script is Yosys EQY.
Official support for [Cadence Jasper Gold](https://www.cadence.com/en_US/home/tools/system-design-and-verification/formal-and-static-verification/jasper-verification-platform/jaspergold-sequential-equivalence-checking-app.html) is not updated, while support for Synopsys and Siemens EDA is not available yet.

## Prerequisites

To run this script using Yosys EQY tool, you will need to install the following tools:

  - [Yosys](https://github.com/YosysHQ/yosys)
  - [yosys-slang](https://github.com/povik/yosys-slang), a SystemVerilog frontend for Yosys. Loaded as a plugin, it provides Yosys the command `read_slang`, to be able to read SystemVerilog files.

  Alternatively, you can install [YosysHQ's OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build), since it provides all these tools pre-built along with their executables.
  

### Usage

From a bash shell, please execute:

```
./sec.sh [-t tool] [-X]
```
Or use `sh ./sec.sh {-t yosys} {-X}` if you run it from a tcsh shell.


### Options
The script options are as follows:


#### **`-t tool`**
Mandatory argument. It selects the SEC tool to be used by the script, where `tool` can be `yosys` (for Yosys EQY), `cadence` (for Cadence Jasper Gold), `synopsys` or `mentor`. Currently, only Yosys EQY is officially supported.

#### **`-X`**
Enable the Core-V eXtension InterFace ([OpenHW CV-X-IF](https://github.com/openhwgroup/core-v-xif/releases/tag/v1.0.0)) for coprocessors support on the RTL design of the cores to be checked. This is effectively done by setting the `XInterface` to `1` on the [`cve2_top`](/rtl/cve2_top.sv) module. 

This option is useful to check if two cores are sequentially equivalent also regarding the eXtension InterFace functionality.

### Example

To perform the SEC script on the current design or state of the repo against the golden reference version, as available on the main branch, with the core functionalities, but without the eXtension Interface (CV32E20 configuration), you can execute the following command from the current directory:

```
./sec.sh -t yosys
```
Or the 'sec' make target from the main `Makefile`, on the root of this repository.
```
make sec
```

### Operation

The script clones the `cve2` `main` branch of the core as a golden reference, and uses the current repository's `rtl` as revised version.


If you want to use another golden reference RTL, Set the `GOLDEN_RTL` environment variable to the new RTL before calling the `sec.sh` script, as shown below:

```
export GOLDEN_RTL=YOUR_GOLDEN_CORE_RTL_PATH
```
or

```
setenv GOLDEN_RTL YOUR_GOLDEN_CORE_RTL_PATH
```
The working directory for this script is defined as [`build/sec/`](/build/sec/), from the root of the repository. If the script succeeds, it returns 0, otherwise 1.  
  

In case it returns 1, you can analyze the build files on the [`/build/sec/reports/`](/build/sec/reports/) directory, which will contains the working files and logs produced during the execution of the script in dated subdirectories. 

Check the main log output on the file `output.{tool name}.log` (`output.yosys.log` for Yosys EQY) to check which signals had failed to match, or if there were other kind of errors.


