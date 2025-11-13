#!/bin/bash

# Copyright (c) 2025 Eclipse Foundation
# Copyright 2023 OpenHW Group
#
# Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://solderpad.org/licenses/
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Config and args parsing
# =======================

CVE2_REPO_BASE="$(readlink -f -- "$( dirname -- "$( readlink -f -- "$0"; )"; )/../../")"
SEC_BUILD_DIR="$CVE2_REPO_BASE/build/sec/"

# Create a working directory for the SEC script on the /build directory
if [ ! -d $SEC_BUILD_DIR ]; then
    mkdir -p $SEC_BUILD_DIR
    # Create a FUSESOC_IGNORE file, so fusesoc ignores this dir when looking
    # for .core files
    touch "$SEC_BUILD_DIR/FUSESOC_IGNORE"
fi

usage() {                                 # Function: Print a help message.
  echo "Usage: $0 [ -t {cadence,mentor,synopsys,yosys} ] [ -X ]" 1>&2
}
exit_abnormal() {                         # Function: Exit with error.
  usage
  exit 1
}

# Disable the CV-X-IF support on the CVE2 by default
XInterface=0

while getopts "t:X" flag
do
    case "${flag}" in
        t) # Choice of SEC tool
            target_tool=${OPTARG}
            ;;
        X) # Enable CV-X-IF support
            XInterface=1
            ;;
        :)
            exit_abnormal
            ;;
        *)
            exit_abnormal
            ;;
    esac
done

if [[ "${target_tool}" != "cadence" && "${target_tool}" != "synopsys" 
    && "${target_tool}" != "mentor" && "${target_tool}" != "yosys" ]]; then
    exit_abnormal
fi

if [[ $XInterface == "1" ]]; then
    echo "CV-X-IF enabled"
fi


# Execution
# =========

if [ ! -d "$SEC_BUILD_DIR/reports/" ]; then
    mkdir -p "$SEC_BUILD_DIR/reports/"
fi

# Obtain the latest code from the main branch, defined as the a Golden version of the design, 
# to be used as reference when performing the checking
GOLDEN_DIR=$(readlink -f $SEC_BUILD_DIR/ref_design/)
if [[ -z "${GOLDEN_RTL}" ]]; then
    echo "The env variable GOLDEN_RTL is empty."
    if [ ! -d "$SEC_BUILD_DIR/ref_design" ]; then
        echo "Cloning Golden Design...."
        git clone https://github.com/openhwgroup/cve2.git $GOLDEN_DIR
    fi
    export GOLDEN_RTL=$GOLDEN_DIR/rtl
else
    echo "SEC: Using ${GOLDEN_RTL} as reference design"
fi

# The proposed design, defined as the Revised version, is the code of the current repo
REVISED_DIR=$CVE2_REPO_BASE

var_golden_rtl=$(awk '{ if ($0 ~ "{DESIGN_RTL_DIR}" && $0 !~ "#" && $0 !~ "tracer" && $0 !~ "wrapper") print $0 }' ${GOLDEN_DIR}/cv32e20_manifest.flist | sed 's|${DESIGN_RTL_DIR}|./ref_design/rtl/|')

var_revised_rtl=$(awk '{ if ($0 ~ "{DESIGN_RTL_DIR}" && $0 !~ "#" && $0 !~ "tracer" && $0 !~ "wrapper") print $0 }' ${REVISED_DIR}/cv32e20_manifest.flist | sed 's|${DESIGN_RTL_DIR}|../../rtl/|')

# Saves the list of concerned RTL files of each version
echo $var_golden_rtl > "$SEC_BUILD_DIR/golden.src"
echo $var_revised_rtl > "$SEC_BUILD_DIR/revised.src"

# Creates a dated report dir, for each run of the script
report_dir="$SEC_BUILD_DIR/reports/$(date +%Y-%m-%d/%H-%M)/"

if [[ -d ${report_dir} ]]; then
    rm -rf ${report_dir}
fi
mkdir -p ${report_dir}

# Tool dependent section
if [[ "${target_tool}" == "cadence" ]]; then
    tcl_script=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))/cadence/sec.tcl
    jg -sec -proj ${report_dir} -batch -tcl ${tcl_script} -define report_dir ${report_dir} &> ${report_dir}/output.cadence.log

    if [ ! -f ${report_dir}/summary.cadence.log ]; then
        echo "Something went wrong during the process" 1>&2
        exit 1
    fi
    grep -Eq "Overall SEC status[ ]+- Complete" ${report_dir}/summary.cadence.log
    RESULT=$?

elif [[ "${target_tool}" == "synopsys" ]]; then
    echo "Synopsys tool is not implemented yet" 1>&2
    exit 1

elif [[ "${target_tool}" == "mentor" ]]; then
    echo "Mentor tool is not implemented yet" 1>&2
    exit 1

elif [[ "${target_tool}" == "yosys" ]]; then
    echo "Using Yosys EQY"

    if [[ -d "$SEC_BUILD_DIR/yosys" ]]; then
        rm -rf "$SEC_BUILD_DIR/yosys"
    fi
    mkdir -p "$SEC_BUILD_DIR/yosys"

    if ! [ -x "$(command -v eqy)" ]; then
        echo "Yosys EQY (eqy) could not be found" 1>&2
        exit 1
    fi

    # Execute Yosys EQY on a separate environment on the build dir.
    # XInterface is passed as an env var, in order to parametrize subsequent scripts
    (
        export XInterface
        cd $SEC_BUILD_DIR && \
        eqy -f $CVE2_REPO_BASE/scripts/sec/yosys/sec.eqy -j $(($(nproc)/2)) -d ${report_dir} &> /dev/null
    )
    mv ${report_dir}/logfile.txt ${report_dir}/output.yosys.log

    if [ -f "${report_dir}/PASS" ]; then 
        RESULT=0
        # rm "$SEC_BUILD_DIR/yosys/golden_io.txt"
    elif [ -f "${report_dir}/FAIL" ]; then 
        RESULT=1
        echo "Check ${report_dir}/output.yosys.log" 1>&2
    else
        echo "Failed to run Yosys EQY" 1>&2
        if [ -f "${report_dir}/output.yosys.log" ]; then
            echo "Check ${report_dir}/output.yosys.log" 1>&2
        fi
        exit 1
    fi
fi

# End of the script
# =================

if [[ $RESULT == 0 ]]; then
    echo "SEC: The DESIGN IS SEQUENTIALLY EQUIVALENT"
    exit 0
else
    echo "SEC: The DESIGN IS NOT SEQUENTIALLY EQUIVALENT" 1>&2
    exit 1
fi
