#!/bin/tclsh


set filename [lindex $argv 0]

package require csv
package require struct::matrix

#Initialisation of matrix
struct::matrix m

#Opening desing details to the file handler f
set f [open $filename]

#parsing csv data into matrix "m"
csv::read2matrix $f m , auto

close $f

set columns [m columns]
set rows [m rows]

#puts "$columns"
#puts "$rows"

m link my_arr

set i 0

#--Data variable creation and data assignment---#
while {$i < $rows} {

	puts "\nInfo: setting $my_arr(0,$i) as $my_arr(1,$i)"

	if {$i == 0} {
		set  [string map {" " ""} $my_arr(0,$i)] $my_arr(1,$i)
	} else {
		set [string map {" " ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
	}
	set i [expr {$i+1}]
}


puts "\nInfo:Below are the list of intial variables and their values"
puts "\nDesignName = $DesignName"
puts "OutputDirectory = $OutputDirectory"
puts "NetlistDirectory = $NetlistDirectory"
puts "EarlyLibraryPath = $EarlyLibraryPath"
puts "LateLibraryPath  = $LateLibraryPath"
puts "ConstraintsFile = $ConstraintsFile"


#--checking whether directories and files mentioned in the csv exists or not---#

if {! [file exists $EarlyLibraryPath] } {
	puts "\nError: cannot find early cell library in $EarlyLibraryPath. Exiting...."
	exit
} else {
	puts "\nInfo: Early cell library found in $EarlyLibraryPath."
}
if {! [file exists $LateLibraryPath] } {
	puts "\nError: cannot find Late cell library in $LateLibraryPath. Exiting...."
	exit
} else {
	puts "\nInfo: Late cell library found in $LateLibraryPath."
}
if {! [file isdirectory $NetlistDirectory] } {
	puts "\nError: cannot find RTL Netlist directory in path $NetlistDirectory. Exiting..."
} else {
	puts "\nInfo: RTL Netlist directory found in $NetlistDirectory"
}
if {! [file isdirectory $OutputDirectory] } {
	puts "\nError: cannot find Output directory in path $OutputDirectory.Creating Directory..."
	file mkdir $OutputDirectory
} else {
	puts "\nInfo: Output directory found in $OutputDirectory"
}
if {! [file exists $ConstraintsFile] } {
	puts "\nError: cannot find Constraints file in $ConstraintsFile. Exiting...."
	exit
} else {
	puts "\nInfo: Constraints file found in $ConstraintsFile."
}

#--Constraints CSV file data processing and converting to format 1 and SDC format----#
puts "\nInfo: Dumping sdc constraints for $DesignName"
::struct::matrix cons
set c1 [open $ConstraintsFile]
csv::read2matrix $c1 cons , auto
close $c1

set c_rows [cons rows]
set ccolumns [cons columns]

puts "\nInfo: Number of rows in constraints file are $c_rows"
puts "\nInfo: Number of columns in constraints file are $ccolumns"

#-check the row and column number for clock-----#
set clk_strt [lindex [lindex [cons search all CLOCKS] 0 ] 1]
set clk_strt_col [lindex [lindex [cons search all CLOCKS] 0 ] 0]
puts "\nInfo: Clock starts from row number $clk_strt"
puts "\nInfo: Clock starts from column number $clk_strt_col"

#--check the row numbers for input and output sections--#

set inp_strt [lindex [lindex [cons search all INPUTS] 0 ] 1]
set out_strt [lindex [lindex [cons search all OUTPUTS] 0 ] 1]
puts "\nInfo: Inputs starts from row number $inp_strt"
puts "\nInfo: Outputs starts from row number $out_strt"

#---Clock latency(delay) constraints---#
#--Finding column number for clock latency in clocks section--#

set clock_erd_start [lindex [lindex [cons search rect $clk_strt_col $clk_strt [expr {$ccolumns-1}] [expr {$inp_strt-1}] early_rise_delay] 0 ] 0]
set clock_efd_start [lindex [lindex [cons search rect $clk_strt_col $clk_strt [expr {$ccolumns-1}] [expr {$inp_strt-1}] early_fall_delay] 0 ] 0]
set clock_lrd_start [lindex [lindex [cons search rect $clk_strt_col $clk_strt [expr {$ccolumns-1}] [expr {$inp_strt-1}] late_rise_delay] 0 ] 0]
set clock_lfd_start [lindex [lindex [cons search rect $clk_strt_col $clk_strt [expr {$ccolumns-1}] [expr {$inp_strt-1}] late_fall_delay] 0 ] 0] 

#--Clock transistion constraints---#
#--Finiding column number for clock transistion in clocks section---#

set clock_ers_start [lindex [lindex [cons search rect $clk_strt_col $clk_strt [expr {$ccolumns-1}] [expr {$inp_strt-1}] early_rise_slew] 0 ] 0]
set clock_efs_start [lindex [lindex [cons search rect $clk_strt_col $clk_strt [expr {$ccolumns-1}] [expr {$inp_strt-1}] early_fall_slew] 0 ] 0]
set clock_lrs_start [lindex [lindex [cons search rect $clk_strt_col $clk_strt [expr {$ccolumns-1}] [expr {$inp_strt-1}] late_rise_slew] 0 ] 0]
set clock_lfs_start [lindex [lindex [cons search rect $clk_strt_col $clk_strt [expr {$ccolumns-1}] [expr {$inp_strt-1}] late_fall_slew] 0 ] 0]

#--Finding column number for frequncy and duty cycle---#

set clock_fre_start [lindex [lindex [cons search rect $clk_strt_col $clk_strt [expr {$ccolumns-1}] [expr {$inp_strt-1}] frequency] 0 ] 0]
set clock_duty_start [lindex [lindex [cons search rect $clk_strt_col $clk_strt [expr {$ccolumns-1}] [expr {$inp_strt-1}] duty_cycle] 0 ] 0]

#puts "column number of clock frequency $clock_fre_start"
#puts "column number of clock duty cycle $clock_duty_start"
#puts "column number of clock erd $clock_erd_start"
#puts "column number of clock efd $clock_efd_start"
#puts "column number of clock lrd $clock_lrd_start"
#puts "column number of clock lfd $clock_lfd_start"

#puts "column number of clock ers $clock_ers_start"
#puts "column number of clock efs $clock_efs_start"
#puts "column number of clock lrs $clock_lrs_start"
#puts "column number of clock lfs $clock_lfs_start"


#--Creating .sdc file with design name in the output directory in write mode---#

set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
set i [expr {$clk_strt +1}]
set end_of_clocks [expr {$inp_strt-1}]

#puts "$i"
#puts "$end_of_clocks"

#---working on printing clock constraints on to the sdc file--#

while {$i < $end_of_clocks} {

puts -nonewline $sdc_file "\ncreate_clock -name [cons get cell 0 $i] -period [cons get cell 1 $i] -waveform \{0 [expr {[cons get cell 1 $i]*[cons get cell 2 $i]/100}] \} \[get_ports [cons get cell 0 $i]\]" 
puts -nonewline $sdc_file "\nset_clock_transition -min -rise [cons get cell $clock_ers_start $i] \[get_clocks [cons get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_transition -min -fall [cons get cell $clock_efs_start $i] \[get_clocks [cons get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_transition -max -rise [cons get cell $clock_lrs_start $i] \[get_clocks [cons get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_transition -max -fall [cons get cell $clock_lfs_start $i] \[get_clocks [cons get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_latency -source -early -rise [cons get cell $clock_erd_start $i] \[get_clocks [cons get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_latency -source -late -fall [cons get cell $clock_lfd_start $i] \[get_clocks [cons get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_latency -source -early -fall [cons get cell $clock_efd_start $i] \[get_clocks [cons get cell 0 $i]\]"
puts -nonewline $sdc_file "\nset_clock_latency -source -late -rise [cons get cell $clock_lrd_start $i] \[get_clocks [cons get cell 0 $i]\]"

set i [expr {$i+1}]
}
 
#---inputs section---------#
#--Finding starting column number for inputs ---#


set input_erd_start [lindex [lindex [cons search rect $clk_strt_col $inp_strt [expr {$ccolumns-1}] [expr {$out_strt-1}] early_rise_delay] 0 ] 0] 
set input_efd_start [lindex [lindex [cons search rect $clk_strt_col $inp_strt [expr {$ccolumns-1}] [expr {$out_strt-1}] early_fall_delay] 0 ] 0]
set input_lrd_start [lindex [lindex [cons search rect $clk_strt_col $inp_strt [expr {$ccolumns-1}] [expr {$out_strt-1}] late_rise_delay] 0 ] 0]
set input_lfd_start [lindex [lindex [cons search rect $clk_strt_col $inp_strt [expr {$ccolumns-1}] [expr {$out_strt-1}] late_fall_delay] 0 ] 0]

set input_ers_start [lindex [lindex [cons search rect $clk_strt_col $inp_strt [expr {$ccolumns-1}] [expr {$out_strt-1}] early_rise_slew] 0 ] 0]
set input_efs_start [lindex [lindex [cons search rect $clk_strt_col $inp_strt [expr {$ccolumns-1}] [expr {$out_strt-1}] early_fall_slew] 0 ] 0]
set input_lrs_start [lindex [lindex [cons search rect $clk_strt_col $inp_strt [expr {$ccolumns-1}] [expr {$out_strt-1}] late_rise_slew] 0 ] 0]
set input_lfs_start [lindex [lindex [cons search rect $clk_strt_col $inp_strt [expr {$ccolumns-1}] [expr {$out_strt-1}] late_fall_slew] 0 ] 0]

set input_related_clock [lindex [lindex [cons search rect $clk_strt_col $inp_strt [expr {$ccolumns-1}] [expr {$out_strt-1}] clocks] 0 ] 0]


#puts "column number of input erd $input_erd_start"
#puts "column number of input efd $input_efd_start"
#puts "column number of input lrd $input_lrd_start"
#puts "column number of input lfd $input_lfd_start"

#puts "column number of input ers $input_ers_start"
#puts "column number of input efs $input_efs_start"
#puts "column number of input lrs $input_lrs_start"
#puts "column number of input lfs $input_lfs_start"
#puts "$input_related_clock"

#--setting variables for input row start and end---#

set i [expr {$inp_strt+1}]
set end_of_inputs [expr {$out_strt-1}]
puts "\nworking on input constraints"
puts "\nCategorizing input ports as bits and busses"

#while loop to write input constraints to the sdc file--#

while { $i < $end_of_inputs } {
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]
foreach f $netlist {
set fd [open $f]
while { [gets $fd line] != -1 } {
set pattern1 " [cons get cell 0 $i];"
if { [regexp -all -- $pattern1 $line] } {
set pattern2 [lindex [split $line ";"] 0]
if { [regexp -all {input} [lindex [split $pattern2 "\S+"] 0]] } {
set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
}
}
}
close $fd
}
close $tmp_file
set tmp_file [open /tmp/1 r]
set tmp2_file [open /tmp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]
set count [llength [read $tmp2_file]]
close $tmp2_file
if {$count > 2} {
set inp_ports [concat [cons get cell 0 $i]*]
#puts "Info: Working on input bus $inp_ports for user debug"
} else {
set inp_ports [cons get cell 0 $i]
#puts "Info : Working on input bit $inp_ports for user debug"
}

#set_input_transition SDC command to set input transition values
puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [cons get cell $input_related_clock $i]\] -min -rise -source_latency_included [cons get cell $input_ers_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [cons get cell $input_related_clock $i]\] -min -fall -source_latency_included [cons get cell $input_efs_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [cons get cell $input_related_clock $i]\] -max -rise -source_latency_included [cons get cell $input_lrs_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_transition -clock \[get_clocks [cons get cell $input_related_clock $i]\] -max -fall -source_latency_included [cons get cell $input_lfs_start $i] \[get_ports $inp_ports\]"

#set_input_delay SDC command to set input latency values
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [cons  get cell $input_related_clock $i]\] -min -rise -source_latency_included [cons get cell $input_erd_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [cons  get cell $input_related_clock $i]\] -min -fall -source_latency_included [cons get cell $input_efd_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [cons  get cell $input_related_clock $i]\] -max -rise -source_latency_included [cons get cell $input_lrd_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [cons  get cell $input_related_clock $i]\] -max -fall -source_latency_included [cons get cell $input_lfd_start $i] \[get_ports $inp_ports\]"
set i [expr {$i+1}]
}

#Output Section

#Finding column number starting for output clock latency in output section

set output_erd_start [lindex [lindex [cons search rect $clk_strt_col $out_strt [expr {$ccolumns-1}] [expr {$c_rows-1}] early_rise_delay] 0 ] 0]
set output_efd_start [lindex [lindex [cons search rect $clk_strt_col $out_strt [expr {$ccolumns-1}] [expr {$c_rows-1}] early_fall_delay] 0 ] 0]
set output_lrd_start [lindex [lindex [cons search rect $clk_strt_col $out_strt [expr {$ccolumns-1}] [expr {$c_rows-1}] late_rise_delay] 0 ] 0]
set output_lfd_start [lindex [lindex [cons search rect $clk_strt_col $out_strt [expr {$ccolumns-1}] [expr {$c_rows-1}] late_fall_delay] 0 ] 0]

#Finding column number starting for output realted clock in output section

set output_related_clock [lindex [lindex [cons search rect $clk_strt_col $out_strt [expr {$ccolumns-1}] [expr {$c_rows-1}] clocks] 0 ] 0]

#Finding column number starting for output load in output section

set output_load_start [lindex [lindex [cons search rect $clk_strt_col $out_strt [expr {$ccolumns-1}] [expr {$c_rows-1}] load] 0 ] 0]


#puts "column number for output erd $output_erd_start"
#puts "column number for output efd $output_efd_start"
#puts "column number for output lrd $output_lrd_start"
#puts "column number for output lfd $output_lfd_start"
#puts "column number for output load $output_load_start"
#puts "column number for output related clock $output_related_clock"

#Setting varibales for actual output row start and end

set i [expr {$out_strt+1}]
set end_of_outputs [expr {$c_rows-1}]

puts "\nInfo: Working on output constraints"
puts "\nInfo: categorizing output ports as bits and busses"

#while loop to write output constraints to the sdc file--#

while { $i < $end_of_outputs } {
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]
foreach f $netlist {
set fd [open $f]
while { [gets $fd line] != -1 } {
set pattern1 " [cons get cell 0 $i];"
if { [regexp -all -- $pattern1 $line] } {
set pattern2 [lindex [split $line ";"] 0]
if { [regexp -all {output} [lindex [split $pattern2 "\S+"] 0]] } {
set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
}
}
}
close $fd
}
close $tmp_file
set tmp_file [open /tmp/1 r]
set tmp2_file [open /tmp/2 w]
puts -nonewline $tmp2_file "[join [lsort -unique [split [read $tmp_file] \n]] \n]"
close $tmp_file
close $tmp2_file
set tmp2_file [open /tmp/2 r]
set count [llength [read $tmp2_file]]
close $tmp2_file
if {$count > 2} {
set op_ports [concat [cons get cell 0 $i]*]
#puts "Info: Working on output bus $op_ports for user debug"
} else {
set op_ports [cons get cell 0 $i]
#puts "Info : Working on output bit $op_ports for user debug"
}

#set_output_delay SDC command to set output latency values

puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [cons get cell $output_related_clock $i]\] -min -rise -source_latency_included [cons get cell $output_erd_start $i] \[get_ports $op_ports\]"
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [cons get cell $output_related_clock $i]\] -min -fall -source_latency_included [cons get cell $output_efd_start $i] \[get_ports $op_ports\]"
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [cons get cell $output_related_clock $i]\] -max -rise -source_latency_included [cons get cell $output_lrd_start $i] \[get_ports $op_ports\]"
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [cons get cell $output_related_clock $i]\] -max -fall -source_latency_included [cons get cell $output_lfd_start $i] \[get_ports $op_ports\]"

#set_load SDC command to set load values

puts -nonewline $sdc_file "\nset_load [cons get cell $output_load_start $i] \[get_ports $op_ports\]"

set i [expr {$i+1}]

}

close $sdc_file
puts "\nInfo-SDC: SDC file created. COnstraints file can be found in the path $OutputDirectory/$DesignName.sdc"


#Heirarachy check

puts "\nInfo: Creating Heirarchy check script to be used by yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.hier.ys"
set fileId [open $OutputDirectory/$filename "w"]
puts -nonewline $fileId $data
set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
puts -nonewline $fileId "\nread_verilog $f"
}
puts -nonewline $fileId "\nhierarchy -check"
close $fileId

#Heirarchy check error handling
#Running Heirarchy check in yosys by dumping log to log file and catching execution message

set error_flag [catch {exec yosys -s $OutputDirectory/$DesignName.hier.ys >& $OutputDirectory/$DesignName.hierarchy_check.log} msg]
if {$error_flag} {
set filename "$OutputDirectory/$DesignName.hierarchy_check.log"
set pattern {referenced in module}
# referenced in module is the statement yosys tool uses to indicate a missing module(Hierarchy Error)
set count 0
set fid [open $filename r]
while { [gets $fid line ] != -1} {
incr count [regexp -all -- $pattern $line]
if { [regexp -all -- $pattern $line] } {
puts "\nError: Module [lindex $line 2] is not a part of the $DesignName. Please correct RTL in the path '$NetlistDirectory'"
puts "\nInfo: Hierarchy check fail"
}
}
close $fid
puts "\nInfo:Please check file hierarchy details in '[file normalize $OutputDirectory/$DesignName.hierarchy_check.log]'"
exit
} else {
puts "\nInfo: Hierarchy check PASS"
puts "\nInfo: Please check file hierarchy details in '[file normalize $OutputDirectory/$DesignName.hierarchy_check.log]'"
}

#Main Synthesis Script

puts "\nInfo: Creating main synthesis script to be used by yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
set filename "$DesignName.ys"
set fileId [open $OutputDirectory/$filename "w"]
puts -nonewline $fileId $data
set netlist [glob -dir $NetlistDirectory *.v]
foreach f $netlist {
puts -nonewline $fileId "\nread_verilog $f"
}
puts -nonewline $fileId "\nhierarchy -top $DesignName"
puts -nonewline $fileId "\nsynth -top $DesignName"
puts -nonewline $fileId "\nsplitnets -ports -format ___\ndfflibmap -liberty ${LateLibraryPath} \nopt"
puts -nonewline $fileId "\nabc -liberty ${LateLibraryPath}"
puts -nonewline $fileId "\nflatten"
puts -nonewline $fileId "\nclean -purge\niopadmap -outpad BUFX2 A:Y -bits\nopt\nclean"
puts -nonewline $fileId "\nwrite_verilog $OutputDirectory/$DesignName.synth.v"
close $fileId
puts "\nInfo: Synthesis Script created and can be accessed from path $OutputDirectory/$DesignName.ys"

puts "\nInfo: Running Synthesis"

#Main synthesis error handling
#Running main synthesis in yosys and dumping log file and catching execution message

if [catch {exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg] {
puts "\nError: Synthesis failed due to errors"
exit
} else {
puts "\nInfo: Synthesis finished Successfully."
}
puts "\nInfo: Please refer to log at $OutputDirectory/$DesignName.synthesis.log"

#Editing .synth.v to a format compatabile for OpenTimer

set fileId [open /tmp/1 "w"]

puts -nonewline $fileId [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
close $fileId
set output [open $OutputDirectory/$DesignName.final.synth.v "w"]
set filename "/tmp/1"
set fid [open $filename r]

while { [gets $fid line] != -1} {
puts -nonewline $output [string map {"\\" ""} $line]
puts -nonewline $output "\n"
}
close $fid
close $output

puts "\nInfo: Find the synthesized final netlist for the design $DesignName at below path. you can use this netlist for STA and PNR."
puts "\nPath : $OutputDirectory/$DesignName.final.synth.v"

#Preparation of .conf and .spef for OpenTimer STA
# Procs used in the below code

puts "\nInfo: TIming analysis started"
puts "\nInfo: Initializing number of threads,libraries,sdc,verilog netlist path..."

#Sourcing required Procs

source /home/vsduser/vsdsynth/procs/reopenStdout.proc
source /home/vsduser/vsdsynth/procs/set_multi_cpu_usage.proc
source /home/vsduser/vsdsynth/procs/read_verilog.proc
source /home/vsduser/vsdsynth/procs/read_lib.proc
source /home/vsduser/vsdsynth/procs/read_sdc.proc

reopenStdout $OutputDirectory/$DesignName.conf
set_multi_cpu_usage -localCpu 4
read_lib -early $EarlyLibraryPath
read_lib -late $LateLibraryPath
read_verilog $OutputDirectory/$DesignName.final.synth.v
read_sdc $OutputDirectory/$DesignName.sdc
reopenStdout /dev/tty

#Writing .spef

set enable_prelayout_timing 1
puts "\nInfo: Setting enable_prelayout_timing as $enable_prelayout_timing to write default .spef with zero-wire load parasitics since, actual .spef is not available. For user debug."
if {$enable_prelayout_timing == 1} {
puts "\nInfo: enable_prelayout_timing is $enable_prelayout_timing. Enabling zero-wire load parasitics"
	set spef_file [open $OutputDirectory/$DesignName.spef w]
	puts $spef_file "*SPEF \"IEEE 1481-1998\" "
	puts $spef_file "*DESIGN \"$DesignName\" "
	puts $spef_file "*DATE \"[clock format [clock seconds] -format {%a %b %d %I:%M:%S %Y}]\" "
	puts $spef_file "*VENDOR \"TAU 2015 Contest\" "
	puts $spef_file "*PROGRAM \"Benchmark Parasitic Generator\" "
	puts $spef_file "*VERSION \"0.0\" "
	puts $spef_file "*DESIGN_FLOW \"NETLIST_TYPE_VERILOG\" "
	puts $spef_file "*DIVIDER / "
	puts $spef_file "*DELIMITER : "
	puts $spef_file "*BUS_DELIMITER \[ \] "
	puts $spef_file "*T_UNIT 1 PS "
	puts $spef_file "*C_UNIT 1 FF "
	puts $spef_file "*R_UNIT 1 KOHM "
	puts $spef_file "*L_UNIT 1 UH "
	close $spef_file
}

# Appending to .conf file
puts "Info: Appending rest of the required commands to .conf file. For user debug."
set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer "
puts $conf_file "report_timer "
puts $conf_file "report_wns "
puts $conf_file "report_worst_paths -numPaths 10000 "
close $conf_file

puts "entering STA analysis using OpenTimer"

#Static Timing Analysis using OpenTimer
#Running STA on OpenTimer dumping log to .results and capturing run time 
set tcl_precision 3
set time_elapsed_in_us [time {exec /home/vsduser/OpenTimer-1.0.5/bin/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results}]
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/1000000.0}]sec"
puts "\nInfo:STA finished in $time_elapsed_in_sec seconds"
puts "\nInfo: Refer to $OutputDirectory/$DesignName.results for warnings and errors"


#Finding worst output violation(RAT)

set worst_RAT_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {RAT}
while { [gets $report_file line] != -1} {
if {[regexp $pattern $line]} {
set worst_RAT_slack "[expr {[lindex $line 3]/1000}]ns"
break
} else {
continue
}
}
close $report_file

puts "worst_RAT_slack is $worst_RAT_slack"

#Finding number of output violations

set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while { [gets $report_file line] != -1} {
incr count [regexp -all -- $pattern $line]
}
set number_output_violations $count
close $report_file

puts "NUmber of output violations are $number_output_violations"




#Finding worst setup violation

set worst_negative_setup_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Setup}
while { [gets $report_file line]!= -1} {
if {[regexp $pattern $line]} {
set worst_negative_setup_slack "[expr {[lindex $line 3]/1000}]ns"
break
} else {
continue
}
}
close $report_file

puts "woorrst_negative_sllack is $worst_negative_setup_slack"



#Finding number of Setup violations

set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while { [gets $report_file line]  != -1} {
incr count [regexp -all -- $pattern $line]
}
set number_of_setup_violations $count
close $report_file

puts "number of setup vioations is $number_of_setup_violations"



#Finding worst Hold violations

set worst_negative_Hold_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Hold}
while { [gets $report_file line] != -1} {
if {[regexp $pattern $line]} {
set worst_negative_Hold_slack "[expr {[lindex $line 3]/1000}]ns"
break
} else {
continue
}
}
close $report_file

puts "worst negative hold slack is $worst_negative_Hold_slack"


#Finding number of Hold violations

set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while { [gets $report_file line] != -1} {
incr count [regexp -all -- $pattern $line]
}
set number_of_Hold_violations $count
close $report_file 

puts "number of hold violations are $number_of_Hold_violations"


#Finding number of instances

set pattern {Num of gates}
set report_file [open $OutputDirectory/$DesignName.results r]
while { [gets $report_file line] != -1} {
if {[regexp -all -- $pattern $line]} {
set instance_count [lindex [join $line " "] 4 ]
puts "$instance_count"
break
} else {
continue
}
}
close $report_file

puts "Instance_COUNT is $instance_count"

# Quality of Results (QoR) generation
puts "\n"
puts "                                                           ****PRELAYOUT TIMING RESULTS****\n"
set formatStr {%15s%14s%21s%16s%16s%15s%15s%15s%15s}
puts [format $formatStr "-----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts [format $formatStr "Design Name" "Runtime" "Instance Count" "WNS Setup" "FEP Setup" "WNS Hold" "FEP Hold" "WNS RAT" "FEP RAT"]
puts [format $formatStr "-----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
foreach design_name $DesignName runtime $time_elapsed_in_sec instance_count $instance_count wns_setup $worst_negative_setup_slack fep_setup $number_of_setup_violations wns_hold $worst_negative_Hold_slack fep_hold $number_of_Hold_violations wns_rat $worst_RAT_slack fep_rat $number_output_violations {
	puts [format $formatStr $design_name $runtime $instance_count $wns_setup $fep_setup $wns_hold $fep_hold $wns_rat $fep_rat]
}
puts [format $formatStr "-----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts "\n"
