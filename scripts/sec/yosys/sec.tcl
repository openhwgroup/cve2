# Copyright (c) 2025 Eclipse Foundation
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


# sec.tcl is an aux Tcl script used to compile RTL files with parameters,
# passed as env vars, with Yosys. 
# This script is called by the Yosys EQY script sec.eqy
#
# Currently the only parameter supported is the CV-X-IF interface
# (XInterface=1)

yosys plugin -i slang

# GOLD or GATE
set DESIGN [lindex $argv 0] 
set XInterface $::env(XInterface)

puts "XInterface: $XInterface"

if {$DESIGN eq "GOLD"} {
    puts "Running GOLD flow"

    yosys read_slang --ignore-assertions -D$DESIGN -G XInterface=$XInterface --top cve2_top -f ./golden.src

    if {$XInterface eq 0} {
        # Exclude specifically the top IO CV-X-IF signals from analysis
        yosys select -set x_interface_set o:\x_* i:\x_*
        yosys delete @x_interface_set
    }

    # Save the list of IO signals, in case the new revised version is different
    yosys select -write yosys/golden_io.txt  o:* i:*

} elseif {$DESIGN eq "GATE"} {
    puts "Running GATE flow"

    yosys read_slang --ignore-assertions -D$DESIGN -G XInterface=$XInterface --top cve2_top -f ./revised.src

    # Delete eventual new IO ports from the revised design from analysis, as we 
    # cannot compare designs with different sets of IO ports

    for {set i 10} {$i >= 0} {incr i -1} {
        if {[file exists "yosys/golden_io.txt"]} {
            break
        } else {
            puts "Attempt [ expr 10-$i+1 ]: yosys/golden_io.txt not found"
            if {$i > 0} {
                after 50
            } else {
                error "yosys/golden_io.txt not found after 10 attempts"
                exit 1
            }
        }
    }
    yosys select -set golden_io -read yosys/golden_io.txt
    yosys select -set revised_io o:* i:*
    yosys select -set excl_sigs @revised_io @golden_io %d
    yosys delete @excl_sigs
    yosys select -write yosys/revised_io.txt  o:* i:*

} else {
    error "Wrong first argument: $DESIGN. Only GOLD or GATE are accepted"
}