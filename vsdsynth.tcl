#!/bin/tclsh

#variable creation
#---------------------------------
# Setting Command Line Argument([lindex $argv 0]) to variable(filename) where argv is a list in TCL.
# lindex is used to retrieve a specific element from the list. 0 indicates teh first element of the list.

set filename [lindex $argv 0]

#packages for processing csv and matrix 
package require csv
package require struct::matrix

#Initialisation of matrix m
struct::matrix m

#opening design details to file handler f
set f [open $filename]

#parsing csv data into matrix "m"
csv::read2matrix $f m , auto

#closing the design details csv
close $f

#storing number of rows and columns of matrix in variables for further use
set columns [m columns] 
set rows [m rows]

#Conversion of matrix to array
m link my_arr

#Auto variable creation and data assignment
set i 0
while {$i < $rows} {
	puts "\nInfo: setting $my_arr(0,$i) as $my_arr(1,$i)"
	if {$i == 0} {
		set [string map {" "  ""} $my_arr(0,$i)] $my_arr(1,$i)
	} else {
		set [string map {" "  ""} $my_arr(0,$i)] [file normalize $my_arr(1,$i)]
	}
	set i [expr {$i + 1}]
}


#----------------------------------------------------------------------------------------------#
#--------Below Script checks whether directories and files mentioned in csv exists or not------#
#----------------------------------------------------------------------------------------------#

if {! [file exists $EarlyLibraryPath] } {
	puts "\nError: Cannot find early cell library in $EarlyLibraryPath. Exiting....."
	exit
} else {
	puts "\nInfo: Early cell library found in the path $EarlyLibraryPath"
}
if {! [file exists $LateLibraryPath] } {
	puts "\nError: Cannot find late cell library in $LateLibraryPath. Exiting......"
	exit
} else {
	puts "\nINfo: Late cell library found in the path $LateLibraryPath"
}
if {! [file isdirectory $NetlistDirectory] } {
	puts "\nError: cannot find RTL Netlist dirctory in path $NetlistDirectory. Exiting ...."
} else {
	puts "\nInfo: RTL Netlist directory found in path $NetlistDirectory"
}
if {! [file isdirectory $OutputDirectory] } {
	puts "\nError: Cannot find output directory $OutputDirectory. Creating Directory...."
	file mkdir $OutputDirectory
} else {
	puts "\nInfo: Output Directory found in path $OutputDirectory"
}
if {! [file exists $ConstraintsFile] } {
	puts "\nError: Cannot find constraints file in path $ConstraintsFile. Exiting....."
	exit
} else {
	puts "\nInfo: Constraints file found in the path $ConstraintsFile"
}

puts "\nInfo: Below are the list of initial variables and their values. User can use these values for further debug."

puts  "DesignName  = $DesignName"
puts  "OutputDirectory = $OutputDirectory"
puts  "NetlistDirectory = $NetlistDirectory"
puts  "EarlyLibraryPath = $EarlyLibraryPath"
puts  "LateLibraryPath  = $LateLibraryPath"
puts  "ConstraintsFile  = $ConstraintsFile"


#-----------Constrisnt file creation-----------------#
#------SDC Format------------------------------------#
#----------------------------------------------------#

puts "\nDumping SDC constraints for $DesignName"
::struct::matrix constraints
set chan [open $ConstraintsFile]
csv::read2matrix $chan constraints , auto
close $chan
set cons_rows [constraints rows]
set cons_columns [constraints columns]
puts "Info: NO.of rows in csv file are $cons_rows"
puts "Info :No.of columns in csv file are $cons_columns"


#check the row number for clock and column number of clock#
set clock_start [lindex [lindex [constraints search all CLOCKS] 0 ] 1]
set clock_start_column [lindex [lindex [constraints search all CLOCKS] 0] 0]
puts "Row from which clock starts = $clock_start"
puts "column from which clock starts = $clock_start_column"

#check for row number for input section in constraints.csv file#
set input_port_start [lindex [lindex [constraints search all INPUTS] 0] 1]
puts "row from which input ports start = $input_port_start"

#check for row number for output section in constraints.csv file#
set output_port_start [lindex [lindex [constraints search all OUTPUTS] 0] 1]
puts "row from which output ports start = $output_port_start"



#--------------------------------------------------------#
#-----------clock latency constraints--------------------#

set clock_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$cons_columns-1}] [expr {$input_port_start -1}] early_rise_delay] 0 ] 0]
set clock_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$cons_columns-1}] [expr {$input_port_start -1}] early_fall_delay] 0 ] 0]
set clock_late_rise_delay_start  [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$cons_columns-1}] [expr {$input_port_start -1}]  late_rise_delay] 0 ] 0]
set clock_late_fall_delay_start  [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$cons_columns-1}] [expr {$input_port_start -1}]  late_fall_delay] 0 ] 0]

#--------------------------------------------------------#
#---------clock transisition constraints-----------------#

set clock_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$cons_columns-1}] [expr {$input_port_start -1}] early_rise_slew] 0 ] 0]
set clock_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$cons_columns-1}] [expr {$input_port_start -1}] early_fall_slew] 0 ] 0]
set clock_late_rise_slew_start  [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$cons_columns-1}] [expr {$input_port_start -1}]  late_rise_slew] 0 ] 0]
set clock_late_fall_slew_start  [lindex [lindex [constraints search rect $clock_start_column $clock_start [expr {$cons_columns-1}] [expr {$input_port_start -1}]  late_fall_slew] 0 ] 0]

set sdc_file [open $OutputDirectory/$DesignName.sdc "w"]
set i [expr {$clock_start + 1}]
set end_of_clock_ports [expr {$input_port_start -1}]
puts "/nInfo: Working on clock constraints"

while { $i < $end_of_clock_ports } {
	#puts "working on clock [constraints get cell 0 $i]"
	puts -nonewline $sdc_file  "\ncreate_clock -name [constraints get cell 0 $i] -period [constraints get cell 1 $i] -waveform \{0 [expr {[constraints get cell 1 $i]*[constraints get cell 2 $i]/100}] \} \[get_ports [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -rise -min [constraints get cell $clock_early_rise_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -fall -min [constraints get cell $clock_early_fall_slew_start $i] \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -rise -max [constraints get cell $clock_late_rise_slew_start $i]  \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_transition -fall -max [constraints get cell $clock_late_fall_slew_start $i]  \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency -source -early -rise [constraints get cell $clock_early_rise_delay_start $i] \[get_clocks [constraints get cell 0 $i]\]" 
	puts -nonewline $sdc_file "\nset_clock_latency -source -early -fall [constraints get cell $clock_early_fall_delay_start $i]  \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency -source -late -rise  [constraints get cell $clock_late_rise_delay_start $i]   \[get_clocks [constraints get cell 0 $i]\]"
	puts -nonewline $sdc_file "\nset_clock_latency -source -late -fall  [constraints get cell $clock_late_fall_delay_start $i]   \[get_clocks [constraints get cell 0 $i]\]"
	set i [expr {$i + 1}]
}

#--------------------------------------------------------------#
#--Create input delay and slew constraints---------------------#
#--------------------------------------------------------------#

set input_early_rise_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$cons_columns-1}] [expr {$output_port_start -1}] early_rise_delay] 0 ] 0]
set input_early_fall_delay_start [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$cons_columns-1}] [expr {$output_port_start -1}] early_fall_delay] 0 ] 0]
set input_late_rise_delay_start  [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$cons_columns-1}] [expr {$output_port_start -1}]  late_rise_delay] 0 ] 0]
set input_late_fall_delay_start  [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$cons_columns-1}] [expr {$output_port_start -1}]  late_fall_delay] 0 ] 0]


set input_early_rise_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$cons_columns-1}] [expr {$output_port_start -1}] early_rise_slew] 0 ] 0]
set input_early_fall_slew_start [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$cons_columns-1}] [expr {$output_port_start -1}] early_fall_slew] 0 ] 0]
set input_late_rise_slew_start  [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$cons_columns-1}] [expr {$output_port_start -1}]  late_rise_slew] 0 ] 0]
set input_late_fall_slew_start  [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$cons_columns-1}] [expr {$output_port_start -1}]  late_fall_slew] 0 ] 0]

set related_clock [lindex [lindex [constraints search rect $clock_start_column $input_port_start [expr {$cons_columns-1}] [expr {$output_port_start -1}] clocks] 0] 0]

set i [expr {$input_port_start +1}]
set end_of_input_port [expr {$output_port_start - 1}]
puts "\nInfo:Working on Input Constraints.."
puts "\nInfo:Caretorizing inputs ports as bits and busses"
while {$i < $end_of_input_port } {
	#------Differentiating the input ports between bits and bus---------#
set netlist [glob -dir $NetlistDirectory *.v]
set tmp_file [open /tmp/1 w]
foreach f $netlist {
	set fd [open $f]
	#puts "Reading file $f"
	while {[gets $fd line] != -1} {     
		set pattern1 " [constraints get cell 0 $i];"
		if {[regexp -all -- $pattern1 $line]}  {
			
			set pattern2 [lindex [split $line ";"] 0]
			if {[regexp -all  {input} [lindex [split $pattern2 "\S+"]0]]} {
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
set count [split [llength [read $tmp2_file]] " "]
#puts "splitting contents of tmp_2 and counting number of elements in $count"
if {$count > 2} {
	set inp_ports [concat [constraints get cell 0 $i]*]
	#puts "working on input bit $inp_ports"
} else {
	set inp_ports [constraints get cell 0 $i] 
	#puts "working on input bit $inp_ports"

}

#------------set input transition SDC commands --------#
puts -nonewline $sdc_file "\nset_input_transisiton -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_slew_start $i] \[get_ports $inp_ports\]" 
puts -nonewline $sdc_file "\nset_input_transisiton -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_slew_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_transisiton -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_slew_start $i] \[get_ports $inp_ports\]"

puts -nonewline $sdc_file "\nset_input_transisiton -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_slew_start $i] \[get_ports $inp_ports\]"


#-----------------set input delay SDC commands-----------#
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $input_early_rise_delay_start $i] \[get_ports $inp_ports\]"
puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $input_early_fall_delay_start $i] \[get_ports $inp_ports\]"

puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $input_late_rise_delay_start $i] \[get_ports $inp_ports\]"

puts -nonewline $sdc_file "\nset_input_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $input_late_fall_delay_start $i] \[get_ports $inp_ports\]"


set i [expr {$i+1}]
}
close $tmp2_file

#----------------------------------------------------------------#
#-------Output Delay and Load Constraints------------------------#
#----------------------------------------------------------------#

puts "output delay constraints"
set output_early_rise_delay_start  [lindex [lindex [constraints search rect $clock_start_column $output_port_start [expr {$cons_columns-1}] [expr {$cons_rows-1}] early_rise_delay] 0] 0]
set output_early_fall_delay_start  [lindex [lindex [constraints search rect $clock_start_column $output_port_start [expr {$cons_columns-1}] [expr {$cons_rows-1}] early_fall_delay] 0] 0]
set output_late_rise_delay_start   [lindex [lindex [constraints search rect $clock_start_column $output_port_start [expr {$cons_columns-1}] [expr {$cons_rows-1}]  late_rise_delay] 0] 0]
set output_late_fall_delay_start   [lindex [lindex [constraints search rect $clock_start_column $output_port_start [expr {$cons_columns-1}] [expr {$cons_rows-1}]  late_fall_delay] 0] 0]

set output_load_start [lindex [lindex [constraints search rect $clock_start_column $output_port_start [expr {$cons_columns-1}] [expr {$cons_rows-1}] load] 0] 0]
set related_clock  [lindex [lindex [constraints search rect $clock_start_column $output_port_start  [expr {$cons_columns-1}] [expr {$cons_rows-1}] clocks] 0] 0]

set i [expr {$output_port_start +1}]
set end_of_output_ports [expr {$cons_rows-1}]

puts "Info:Working on output constraints:.."
puts "Info:SDC Categorizing output ports as bits and busses"

while {$i < $end_of_output_ports} {
	set netlist [glob -dir $NetlistDirectory *.v]
	set tmp_file [open /tmp/1 w]
	foreach f $netlist {
		set fd [open $f]
		while {[gets $fd line] != -1} {
                set pattern1 " [constraints get cell 0 $i];"
                if {[regexp -all -- $pattern1 $line]}  {
                        #puts "pattern1"
                        set pattern2 [lindex [split $line ";"] 0]
                        #puts "pattern2"
                        if {[regexp -all  {input} [lindex [split $pattern2 "\S+"]0]]} {
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
set count [split [llength [read $tmp2_file]] " "]
if {$count > 2} {
        set op_ports [concat [constraints get cell 0 $i]*]
        #puts "working on output bit $op_ports"
} else {
        set op_ports [constraints get cell 0 $i]
       # puts "working on output bit $op_ports"

}


#-----------------set output delay SDC commands-----------#

puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -rise -source_latency_included [constraints get cell $output_early_rise_delay_start $i] \[get_ports $op_ports\]"
puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -min -fall -source_latency_included [constraints get cell $output_early_fall_delay_start $i] \[get_ports $op_ports\]"

puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -rise -source_latency_included [constraints get cell $output_late_rise_delay_start $i] \[get_ports $op_ports\]"

puts -nonewline $sdc_file "\nset_output_delay -clock \[get_clocks [constraints get cell $related_clock $i]\] -max -fall -source_latency_included [constraints get cell $output_late_fall_delay_start $i] \[get_ports $op_ports\]"

puts -nonewline $sdc_file "\nset_load [constraints get cell $output_load_start $i] \[get_ports $op_ports\]"

set i [expr {$i+1}]

}

close $tmp2_file
close $sdc_file

puts "Info:SDC file created. Use constraints from the path $OutputDirectory/$DesignName.sdc"

#------------------------------------------------------------------#
#---------------Heirarchy Check------------------------------------#
#------------------------------------------------------------------#

puts "\nInfo: Creating Heirarchy check script to be used by Yosys"
set data "read_liberty -lib -ignore_miss_dir -setattr blackbox ${LateLibraryPath}"
puts "data is \"$data\""
set filename "$DesignName.hier.ys"
puts "filename is \"$filename\""
set fileId [open $OutputDirectory/$filename "w"]
puts -nonewline $fileId $data

set netlist [glob -dir $NetlistDirectory *.v]
#puts "netlist is \"$netlist\""
foreach f $netlist {
	puts -nonewline $fileId "\nread_verilog $f"
	#puts "$f"
}
puts -nonewline $fileId "\nhierarchy -check"
close $fileId

set error_flag [catch {exec yosys -s $OutputDirectory/$DesignName.hier.ys >& $OutputDirectory/$DesignName.hierarchy_check.log} msg]
puts "$error_flag"
if {$error_flag} {
	set filename "$OutputDirectory/$DesignName.hierarchy_check.log"
	set pattern {referenced in module}
	set count 0
	set fid [open $filename r]
	while {[gets $fid line] != -1} {
		incr count [regexp -all -- $pattern $line]
		if { [regexp -all -- $pattern $line]} {
			puts "\nError: module [lindex $line 2] is not a part of design $DesignName"
		       puts "\nInfo: Hierarchy check fail"
       }
}
close $fid
} else {
	puts "\nInfo: Hierarchy check PASS"
}
puts "\nInfo: Please find Hierarchy check details in [file normalize $OutputDirectory/$DesignName.hierarchy_check.log] for more info.Exiting"


#---------------------------------------------------------------------#
#--------------Main Synthesis Script----------------------------------#
#---------------------------------------------------------------------#

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
puts -nonewline $fileId "\nsplitnets -ports -format ___ \ndfflibmap -liberty ${LateLibraryPath} \nopt"
puts -nonewline $fileId "\nabc -liberty ${LateLibraryPath}"
puts -nonewline $fileId "\nflatten"
puts -nonewline $fileId "\nclean -purge\niopadmap -outpad BUFX2 A:Y -bits\nopt\nclean"
puts -nonewline $fileId "\nwrite_verilog $OutputDirectory/$DesignName.synth.v    "
close $fileId
puts "\nSynthesis Script created and can be accessed from path $OutputDirectory/$DesignName.ys"
puts "\nRunning synthesis"

#--------------------------------------------------------------------#
#-------Running synthesis script using yosys-------------------------#
#--------------------------------------------------------------------#

if {[catch {exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg]} {
       puts "\nError: Synthesis failed due to errors. Please refer to log $OutputDirectory/$DesignName.synthesis.log for errors...."
       exit
} else {
	puts "\nSynthesis finished successfully"
       }
puts "\nInfo: Please refer to log $OutputDirectory/$DesignName.synthesis.log"


#--------------------------------------------------------------------#
#----------Edit synth.v to be usable by opentimer--------------------#
#--------------------------------------------------------------------#

set fileId [open /tmp/1 "w"]
puts -nonewline $fileId [exec grep -v -w "*" $OutputDirectory/$DesignName.synth.v]
close $fileId

set output [open $OutputDirectory/$DesignName.final.synth.v "w"]

set filename "/tmp/1"
set fid [open $filename r]
	while {[gets $fid line] != -1} {
		puts -nonewline $output [string map {"\\" ""} $line]
		puts -nonewline $output "\n"
	}
close $fid
close $output

puts "\nInfo: Please find the synthesized netlist for $DesignName at below path.you can use this Netlist for STA and PNR"
puts "\n$OutputDirectory/$DesignName.final.synth.v"

#--------------------------------------------------------------------#
#----------static timing analysis using opentimer--------------------#
#--------------------------------------------------------------------#

puts "\nInfo: Timing Analysis started..."
puts "\nInfo: Initializing number of threads,libraries,sdc,verilog netlist path..."

source /home/vsduser/vsdsynth/procs/reopenStdout.proc
source /home/vsduser/vsdsynth/procs/set_num_threads.proc
reopenStdout $OutputDirectory/$DesignName.conf
set_multi_cpu_usage -localCpu 4


source /home/vsduser/vsdsynth/procs/read_lib.proc
read_lib -early /home/vsduser/vsdsynth/osu018_stdcells.lib

read_lib -late  /home/vsduser/vsdsynth/osu018_stdcells.lib

source /home/vsduser/vsdsynth/procs/read_verilog.proc
read_verilog $OutputDirectory/$DesignName.final.synth.v


source /home/vsduser/vsdsynth/procs/read_sdc.proc
read_sdc $OutputDirectory/$DesignName.sdc
reopenStdout /dev/tty

# Continue to write .conf and also write a .spef
# Writing .spef
set enable_prelayout_timing 1
#puts "Info: Setting enable_prelayout_timing as $enable_prelayout_timing to write default .spef with zero-wire load parasitics since, actual .spef is not available. For user debug."
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
#puts "Info: Appending rest of the required commands to .conf file. For user debug."
set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer "
puts $conf_file "report_timer "
puts $conf_file "report_wns "
puts $conf_file "report_worst_paths -numPaths 10000 "
close $conf_file

# Static Timing Analysis using OpenTimer
# --------------------------------------
# Running STA on OpenTimer and dumping log to .results and capturing runtime
set tcl_precision 3
set time_elapsed_in_us [time {exec /home/vsduser/OpenTimer-1.0.5/bin/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results}]
#puts "Info: time_elapsed_in_us = $time_elapsed_in_us. For user debug."
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/1000000.0}]sec"
#puts "Info: time_elapsed_in_sec = $time_elapsed_in_sec. For user debug."
puts "\nInfo: STA finished in $time_elapsed_in_sec seconds"
puts "\nInfo: Refer to $OutputDirectory/$DesignName.results for warnings and errors"


# Find worst output violation
set worst_RAT_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {RAT}
while { [gets $report_file line] != -1 } {
	if {[regexp $pattern $line]} {
		set worst_RAT_slack "[expr {[lindex $line 3]/1000}]ns"
		break
	} else {
		continue
	}
}
close $report_file

# Find number of output violation
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while { [gets $report_file line] != -1 } {
	incr count [regexp -all -- $pattern $line]
}
set Number_output_violations $count
close $report_file

# Find worst setup violation
set worst_negative_setup_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Setup}
while { [gets $report_file line] != -1 } {
	if {[regexp $pattern $line]} {
		set worst_negative_setup_slack "[expr {[lindex $line 3]/1000}]ns"
		break
	} else {
		continue
	}
}
close $report_file

# Find number of setup violation
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while { [gets $report_file line] != -1 } {
	incr count [regexp -all -- $pattern $line]
}
set Number_of_setup_violations $count
close $report_file

# Find worst hold violation
set worst_negative_hold_slack "-"
set report_file [open $OutputDirectory/$DesignName.results r]
set pattern {Hold}
while { [gets $report_file line] != -1 } {
	if {[regexp $pattern $line]} { 
		set worst_negative_hold_slack "[expr {[lindex $line 3]/1000}]ns"
		break
	} else {
		continue
	}
}
close $report_file

# Find number of hold violation
set report_file [open $OutputDirectory/$DesignName.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all -- $pattern $line]
}
set Number_of_hold_violations $count
close $report_file

# Find number of instance
set pattern {Num of gates}
set report_file [open $OutputDirectory/$DesignName.results r]
while {[gets $report_file line] != -1} {
	if {[regexp -all -- $pattern $line]} {
		set Instance_count [lindex [join $line " "] 4 ]
		break
	} else {
		continue
	}
}
close $report_file

# Capturing end time of the script
set end_time [clock clicks -microseconds]

# Setting total TCL script runtime to 'time_elapsed_in_sec' variable instead of just STA
puts "Info: TCL script total runtime is $time_elapsed_in_sec. For user debug."

puts "\nInfo: Below are the list of variable values. For user debug."
puts "Design_Name is \{$DesignName\}" 
puts "time_elapsed_in_sec is \{$time_elapsed_in_sec\}"
puts "Instance_count is \{$Instance_count\}"
puts "worst_negative_setup_slack is \{$worst_negative_setup_slack\}"
puts "Number_of_setup_violations is \{$Number_of_setup_violations\}"
puts "worst_negative_hold_slack is \{$worst_negative_hold_slack\}"
puts "Number_of_hold_violations is \{$Number_of_hold_violations\}"
puts "worst_RAT_slack is \{$worst_RAT_slack\}"
puts "Number_output_violations is \{$Number_output_violations\}"


# Quality of Results (QoR) generation
puts "\n"
puts "                                                           ****PRELAYOUT TIMING RESULTS****\n"
set formatStr {%15s%14s%21s%16s%16s%15s%15s%15s%15s}
puts [format $formatStr "-----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts [format $formatStr "Design Name" "Runtime" "Instance Count" "WNS Setup" "FEP Setup" "WNS Hold" "FEP Hold" "WNS RAT" "FEP RAT"]
puts [format $formatStr "-----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
foreach design_name $DesignName runtime $time_elapsed_in_sec instance_count $Instance_count wns_setup $worst_negative_setup_slack fep_setup $Number_of_setup_violations wns_hold $worst_negative_hold_slack fep_hold $Number_of_hold_violations wns_rat $worst_RAT_slack fep_rat $Number_output_violations {
	puts [format $formatStr $design_name $runtime $instance_count $wns_setup $fep_setup $wns_hold $fep_hold $wns_rat $fep_rat]
}
puts [format $formatStr "-----------" "-------" "--------------" "---------" "---------" "--------" "--------" "-------" "-------"]
puts "\n"
