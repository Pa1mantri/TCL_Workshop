# Introduction
A unique User-Interface that will take RTL Netlist and SDC Constraints as input and will generate synthesized netlist and pre-layout timing report as output using TCL Programming. TCL box is the user interface that is going to be designed to represent the data in the following format. 

<img width="601" alt="Screenshot 2023-11-09 121409" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/009c9986-3716-4d01-bf73-7109bb5d5316">

# TCL Scripting

Using TCL Scripting, here we will convert the data present in the .csv file( excel kind of file, where data is represented and separated by commas, in libreoffice it is represented in tabular form) into a data sheet.

<img width="930" alt="Screenshot 2023-11-01 113352" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/fa9fa4ab-a614-46a0-a6ed-63775739f1b3">

All the files that are present in the above file are sourced from vsdsynth folder.

<img width="931" alt="Screenshot 2023-11-06 170549" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/b1ecf608-dc71-4167-80d3-00291edba9fc">

The process converting this .csv file data into data sheet using TCL script is divided into three sub-tasks.

1. Create command named “vsdsynth” which takes the .csv file and passes the .csv file to TCL script.
2. Convert all the inputs in the .csv file into two different formats. One is format1 and the other is sdc format.
    
Similarly there is another file openMSP430_design_constraints_csv files which looks like the image below 
    
 <img width="930" alt="Screenshot 2023-11-01 120111" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/a80dd716-35dd-4d77-9eb4-c54520330cbe">

 <img width="960" alt="Screenshot 2023-11-01 120342" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/390ec9f5-81d4-475b-882a-08ab1c934d0b">
     
 This has to be converted into SDC (Synopsys Design Constraint) format. SDC format is a standard representation across the industry, acceptable to all the CAD tools. This 
 conversion also happens using TCL Script. This is the second sub-task apart from creating a command(i.e. 1st sub-task)
    
3. Next Sub-task is to convert this format[1] data & SDC data into different format i.e. format2 and pass it to timing tool “**Opentimer**”. opentimer accepts command in this fashion
    
    This Opentimer tool is responsible for creating the **final data sheet representation** of the .csv file which is given as input.  Finally the output report should be generated in the format shown in the image below. The input is a .csv file and after performing all the sub-tasks the output should look like this.
    
   <img width="607" alt="Screenshot 2023-11-01 121916" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/6592a9b0-69e4-4bdc-90dd-6ee668000d15">
    
    Now, we will go through the sub-tasks one by one.
   

**Sub-Task - 1 Building the command “vsdsynth” and passing .csv from UNIX to TCL script**

Every shell script starts with #!/bin/tcsh -f

We consider three cases while sending the csv file to the TCL script.

1. csv file not sent as argument in the command  ./vsdsynth
2. csv file not present in the same directory  ./vsdsynth my.csv
3. while using the command -help along with the command ./vsdsynth

<img width="927" alt="Screenshot 2023-11-01 164852" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/76660a00-b0d2-4eef-ab78-c57dba552138">

The first “if module” checks, whether there is argument present along with the command, if not, it echos “Please provide the csv file”. $#argv returns a number depending upon the number of arguments sent along with the command ./vsdsynth. Here only one argument(csv file) is expected so, we are equating it with 1.

<img width="579" alt="Screenshot 2023-11-01 165652" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/5c051d07-1e7f-4be1-8a88-d92c678217c6">

The second “if module” checks whether the argument sent is a csv file or a help command. If it is not help command , it checks whether the csv file is present in the same directory or not. If not, it display “cannot find file.” If it is a help command it display whatever is written in the echo statements. 

<img width="866" alt="Screenshot 2023-11-01 165750" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/d65bcbe6-137b-4ec7-a310-e171a32f7edf">

If the correct csv file is sent and argument is not a help command, the csv file is then moved to the TCL script vsdsynth.tcl which is run by the tcl shell. It is represented in the else block at the end.

<img width="748" alt="Screenshot 2023-11-01 170451" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/94ad73d0-e26f-445d-b25d-dc1fc23227b9">

**Second Sub-Task** Convert all inputs to foramt[1] and SDC format and pass it to synthesis tool for generating synthesis report and netlist files.

This sub-task is further divided into steps

- Create Variables
- Check if directories and files mentioned in .csv file exists or not
- Read constraints file for above .csv file and convert to SDC format
- Read all files in the Netlist directory
- Create main synthesis script in format[2]
- Pass this script to yosys

How do we access the csv file inside the vsdsynth.tcl TCL file. We are sending the file to tcl script using the command **tclsh vsdsynth.tcl $argv[1].** 

**Create Variables: Converting the excel sheet into Variables**

By creating variables, we mean , we need to make sure the Design name refers to the OpenMSP430

OutputDirectory refers to the /outdir_OpenMSP430 and so on.

Various steps involved in creating variables are, first converting the excel(csv file) data into a matrix and then convert the matrix into an array. Reason for converting a matrix into an array is: you can access any individual block(cell) like my_arr[1,2].

<img width="944" alt="Screenshot 2023-11-02 144130" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/d6972ec6-5826-4999-b4df-99f59e10b7c1">

Command to create a matrix object with matrix name m is **struct :: matrix m**

**set f [open $filename] :  [open $filename]** will open a file in read mode and that particular instruction is stored in the variable f. If we want to do any processing to the csv file(like counting the number of rows, columns) first step is to open the file in read mode. $f variable will help us do any processing on the file.

**csv :: read2matrix $f m, auto**  Convert the file($f) which is in open(read) mode into a matrix, use the comma as the separator to form different cells in the matrix, auto command will automatically identifies the size of the matrix.

<img width="912" alt="Screenshot 2023-11-02 151748" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/8cf2cedc-194c-4d77-9016-e353a71a5039">

**close $f :** Since all the information of the csv files is now included in the matrix, we can close the file.

**set columns [m columns]** will return the number of columns in the matrix above. Auto command already identified the number the rows and columns in the above step. Having a variable to address the number of columns is an advantage. we can use it variable further. Similarly for rows,               **set num_of_rows [m rows]** will gives the value of no of rows in the matrix.

**m link my_arr**  Convert the matrix into an array

Now we will run a loop which will set the design name to OpenMSP430 and all the other variables to the respective paths. In the matrix form, they all are independent entities. We will correlate each one with the respective paths.

<img width="605" alt="Screenshot 2023-11-02 154915" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/12f17240-ed59-4f4b-9ddb-aa5cd73b4ce3">

Info: Setting Design name as ‘OpenMSP_430’

<img width="937" alt="Screenshot 2023-11-02 160043" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/e32e1c86-e81c-42b7-ae56-5ebf949efc48">

Here first variable is set. i.e. DesignName variable is set to $my_arr(1,0);  string map helps in removing the space between the Design Name. After this step **$DesignName = openMSP_430**

**file normalize** will remove the tilda(~) and replace with the absolute path

After auto creating all the variables, this is how it should be

<img width="398" alt="Screenshot 2023-11-03 170227" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/0ffb5b1d-632a-46b2-a90f-63b7ce5b4c4b">

In a similar way how we convert the design_details.csv file into a matrix and, we perform the same action to the constraints.csv file.

After finding the row numbers from which input , output and clock port starts. First start the script by processing the clock constraints in the csv file.

<img width="881" alt="Screenshot 2023-11-04 111746" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/4fffd0cf-40e4-4ea0-8176-b449735e3614">

TCL script for processing clock constraints

Code
```
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
puts "$cons_rows"
puts "$cons_columns"


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
	puts "working on clock [constraints get cell 0 $i]"
	puts -nonewline $sdc_file  "\ncreate_clock -name [constraints get cell 0 $i] -period [constraints get cell 1 $i] -waveform \{0 [expr {[constraints get cell 1 $i]*[constraints get cell 2 $i]/100}] \}\[get_ports [constraints get cell 0 $i]\]"
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

```

<img width="936" alt="Screenshot 2023-11-04 190457" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/0205f418-8d45-4592-9ac2-66e16d517e8d">

<img width="834" alt="Screenshot 2023-11-04 190513" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/a1834b10-333e-443c-877f-e9b76bc9d3e9">

Code
```
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
puts "\nInfo:Working on IO Constraints.."
puts "\nInfo:Caretorizing inputs as bits and busses"
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
			#puts "pattern1"
			set pattern2 [lindex [split $line ";"] 0]
			#puts "pattern2"
			if {[regexp -all  {input} [lindex [split $pattern2 "\S+"]0]]} {
				#puts "Out of all patterns, $pattern2"
				set s1 "[lindex [split $pattern2 "\S+"] 0] [lindex [split $pattern2 "\S+"] 1] [lindex [split $pattern2 "\S+"] 2]"
				#puts "Printing first three elements of pattern2 \"$s1\" using space as delimiter"
				puts -nonewline $tmp_file "\n[regsub -all {\s+} $s1 " "]"
				#puts "replace multiple spaces using one space as \"[regsub -all {\s+} $s1 " "]\""
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
#puts "splitting contents of tmp_2 and counting number of elements in $count"
if {$count > 2} {
	set inp_ports [concat [constraints get cell 0 $i]*]
	#puts "bussed"
} else {
	set inp_ports [constraints get cell 0 $i] 
	#puts "not bussed"

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

```
Generated SDC file generated in the output directory after reading the values from the csv file

<img width="598" alt="Screenshot 2023-11-04 190423" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/80361042-0b0f-4110-a892-28ce1861ee40">

**Processing input constraints**

**set netlist [glob -dir $NetlistDirectory *.v]**  This command helps in getting all the .v files inside the NetlistDirectory. We can access all these files using $netlist variable.

**set tmp_file [open /tmp/1 w]**  Opening a temporary file in write mode.

SDC file after input constraints are added into file through TCL script

<img width="681" alt="Screenshot 2023-11-05 184741" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/81f417d4-c642-4d98-83a1-e6abe99353cb">

After searching the SDC file using grep command, to check the bussed signals, which are represented using *.

<img width="660" alt="Screenshot 2023-11-05 184635" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/c3a3db42-e576-4a17-b415-aec5b34ebb49">

**Processing Output delay and load Constraints**

Code

```
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
        puts "working on output bit $op_ports"
} else {
        set op_ports [constraints get cell 0 $i]
        puts "working on output bit $op_ports"

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

```
<img width="921" alt="Screenshot 2023-11-06 171601" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/5c74c0f3-8f59-4db5-a529-ef63d1958e9c">

SDC file after output constraints are generated

<img width="929" alt="Screenshot 2023-11-06 171649" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/2afb76ab-29b9-48ae-9521-b0d8a49bb1b4">

**Memory Module Yosys Synthesis and Explanation**

The Verilog code for a single bit address and single bit data Memory unit is given below

```
memory module (CLK, ADDR, DIN, DOUT)

parameter wordSize =1;
parameter addressSize = 1;

input ADDR,CLK;
input [wordSize-1:0] DIN;
output reg [wordSize-1:0] DOUT;
reg [wordSize:0] mem [0:(1<<addrSize)-1];

always@(posedge CLK)
begin
mem[ADDR] <=DIN;
DOUT <= mem[ADDR];
end
endmodule
```
The basic Yosys script to run this and obtain a gate-level netlist of the memory module is given below.
<img width="612" alt="Screenshot 2023-11-06 161307" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/8195f5ee-0624-4534-8e7d-dc2768859c7b">

The output view of the netlist from the code is shown below
<img width="610" alt="Screenshot 2023-11-06 161322" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/3c022387-ad9a-410b-aaa0-c04fb16115e4">

Memory write process is explained in the following images.
Memory Write

<img width="619" alt="Screenshot 2023-11-06 161333" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/b6e769d3-f03f-4f73-b67a-92394bdeaa4e">

Before First rising edge of the clock

<img width="610" alt="Screenshot 2023-11-06 161424" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/5e1f0718-4f64-453a-93e2-28301d6fe8ad">

After first rising edge of the clock. Memory write is Done.

<img width="615" alt="Screenshot 2023-11-06 161435" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/74dc11a2-900d-4b3a-86d3-cabb88d7bb21">

Memory Read process is explained below. 
Memory Read

<img width="612" alt="Screenshot 2023-11-06 161451" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/0ea11920-8621-4984-b463-0877266e3e76">

After the first rising edge and before the second rising edge of the clock

<img width="607" alt="Screenshot 2023-11-06 161508" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/93bf23ea-a1c7-4a19-a209-50dddc87914e">

After the second rising edge. Memory Read is done.

<img width="611" alt="Screenshot 2023-11-06 161521" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/eb47aae1-9869-4428-98b4-0a185f9c43e0">

**Heirarchy Check Script dumping**
This will list all the verilog files present in the netlist directory. 
<img width="930" alt="Screenshot 2023-11-06 144321" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/97e67aa7-8dad-4969-bcc9-e28862d72638">

openMSP430.hier.ys
<img width="928" alt="Screenshot 2023-11-06 163750" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/0d209f31-231d-48cf-8114-107af26827cf">

**Heirarchy Check Run and Error Handling**
If there is any error like missing a module used in the top level module, the script stops throwing an error Heirarchy Fails.

Heirarchy check FAIL 
<img width="935" alt="Screenshot 2023-11-06 155817" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/4449a976-a3f9-4e72-99f8-ca015646756e">

<img width="927" alt="Screenshot 2023-11-06 155844" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/6d18c1ea-b52a-4fb5-8ed8-45efa1b11c30">

Heirarchy check PASS 
<img width="929" alt="Screenshot 2023-11-06 155943" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/7a91cdf8-9974-443c-a910-46a584401e11">

<img width="931" alt="Screenshot 2023-11-06 160034" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/5d216c9f-a8da-4bb0-816d-80aba4095afa">

**Main yosys synthesis script dumping**
Code
```
#--------------Main Synthesis Script----------------------------------#

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

```
Synthesis script openMSP430.ys has been created. This script is used to run the synthesis using yosys tool.


<img width="926" alt="Screenshot 2023-11-07 173330" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/f05bebc1-106e-460c-a12a-622017f48b3e">

<img width="928" alt="Screenshot 2023-11-07 181054" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/15b3d4d0-ce4e-4d09-a58d-8f1ae8629391">


**Main synthesis Error Handling script**
Code

```
#-------Running synthesis script using yosys-------------------------#

if {[catch {exec yosys -s $OutputDirectory/$DesignName.ys >& $OutputDirectory/$DesignName.synthesis.log} msg]} {
       puts "\nError: Synthesis failed due to errors. Please refer to log $OutputDirectory/$DesignName.synthesis.log for errors...."
       exit
} else {
	puts "\nSynthesis finished successfully"
       }
puts "\nInfo: Please refer to log $OutputDirectory/$DesignName.synthesis.log"

```
Synthesized Netlist is generated during this step.

<img width="909" alt="Screenshot 2023-11-07 180430" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/de1880e4-ad15-47e1-bcdd-0efc1a95786f">

Synthesis failed step

<img width="913" alt="Screenshot 2023-11-07 192127" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/2c8b18ce-fcdf-4d20-9e75-a19313c64645">

<img width="929" alt="Screenshot 2023-11-07 192213" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/b6b78b9c-0888-4757-af2c-72530b57732f">


**Editing synth.v to be usable by opentimer**
Code
```
#----------Edit synth.v to be usable by opentimer--------------------#

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


```
synth.v file has to be editied to make it usable for opentimer. "*" inside the netlist file are replaced and are considered as word, and removing "" from all the lines that have "".

/tmp/1

<img width="928" alt="Screenshot 2023-11-07 193116" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/445bff6c-e0ea-4304-9430-d12ebc3b08ff">

openMSP430.synth.v

<img width="915" alt="Screenshot 2023-11-07 193320" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/762febdb-8763-4e07-9675-6983b534d96e">

openMSP430.synth.final.v

<img width="929" alt="Screenshot 2023-11-07 193334" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/e894642e-ec23-4d42-ae11-da1c878fe809">

**World of Procs (TCL Procedure)**
Procs can be used to define user-defined commands.

*reopenStdout.proc*

```
#!/bin/tclsh
proc reopenStdout {file} {
	close stdout
	open $file w
}
```

*set_multi_cpu_usage.proc*

This procs outputs the multiple threads of cpu usage command required for opentimer tool.

Code
```
#!/bin/tclsh

proc set_multi_cpu_usage {args} {
        array set options {-localCpu <num_of_threads> -help "" }
        while {[llength $args]} {
                switch -glob -- [lindex $args 0] {
                	-localCpu {
				set args [lassign $args - options(-localCpu)]
				puts "set_num_threads $options(-localCpu)"
			}
                	-help {
				set args [lassign $args - options(-help) ]
				puts "Usage: set_multi_cpu_usage -localCpu <num_of_threads> -help"
				puts "\t-localCpu - To limit CPU threads used"
				puts "\t-help - To print usage"
                      	}
                }
        }
}
```

<img width="913" alt="1" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/c9d5e6ff-3a5b-4b0d-a812-4423864afea8">

*read_lib.proc*
Code

```
#!/bin/tclsh

proc read_lib args {
	# Setting command parameter options and its values
	array set options {-late <late_lib_path> -early <early_lib_path> -help ""}
	while {[llength $args]} {
		switch -glob -- [lindex $args 0] {
		-late {
			set args [lassign $args - options(-late) ]
			puts "set_late_celllib_fpath $options(-late)"
		      }
		-early {
			set args [lassign $args - options(-early) ]
			puts "set_early_celllib_fpath $options(-early)"
		       }
		-help {
			set args [lassign $args - options(-help) ]
			puts "Usage: read_lib -late <late_lib_path> -early <early_lib_path>"
			puts "-late <provide late library path>"
			puts "-early <provide early library path>"
			puts "-help - Provides user deatails on how to use the command"
		      }	
		default break
		}
	}
}

```
*read_verilog.proc*

This procs outputs commands that are used to read the synthesized netlist required for the opentimer tool.

```
#!/bin/tclsh

# Proc to convert read_verilog to OpenTimer format
proc read_verilog {arg1} {
	puts "set_verilog_fpath $arg1"
}
```
<img width="933" alt="Screenshot 2023-11-08 154616" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/96d3dacd-4858-47c9-bf0c-b8740530ce7f">

Conf file output till the read_verilog propc

<img width="928" alt="Screenshot 2023-11-08 154602" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/153b77ca-e39b-45df-b0ba-41afde8113c5">

*read_sdc.proc*

This procs converts SDC file contents to .timing file format for use by the OpenTimer tool, and the conversion code is explained stage by stage.

__Converting create_clock constraints__

Initially, the proc takes the SDC file as an input argument or parameter and processes the 'create_clock' constraints part of SDC.

```
#!/bin/tclsh

proc read_sdc {arg1} {

# 'file dirname <>' to get directory path only from full path
set sdc_dirname [file dirname $arg1]
# 'file tail <>' to get last element
set sdc_filename [lindex [split [file tail $arg1] .] 0 ]
set sdc [open $arg1 r]
set tmp_file [open /tmp/1 w]

# Removing "[" & "]" from SDC for further processing the data with 'lindex'
# 'read <>' to read entire file
puts -nonewline $tmp_file [string map {"\[" "" "\]" " "} [read $sdc]]     
close $tmp_file

# Opening tmp file to write constraints converted from generated SDC
set timing_file [open /tmp/3 w]

# Converting create_clock constraints
# -----------------------------------
set tmp_file [open /tmp/1 r]
set lines [split [read $tmp_file] "\n"]
# 'lsearch -all -inline' to search list for pattern and retain elementas with pattern only
set find_clocks [lsearch -all -inline $lines "create_clock*"]
foreach elem $find_clocks {
	set clock_port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
	set clock_period [lindex $elem [expr {[lsearch $elem "-period"]+1}]]
	set duty_cycle [expr {100 - [expr {[lindex [lindex $elem [expr {[lsearch $elem "-waveform"]+1}]] 1]*100/$clock_period}]}]
	puts $timing_file "\nclock $clock_port_name $clock_period $duty_cycle"
}
close $tmp_file
```
__Converting 'set_clock_latency' constraints__

Code

```
# Converting set_clock_latency constraints
# ----------------------------------------
set find_keyword [lsearch -all -inline $lines "set_clock_latency*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_clocks"]+1}]]
	if {![string match $new_port_name $port_name]} {
        	set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_clocks"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
		puts -nonewline $tmp2_file "\nat $port_name $delay_value"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file
```
__Converting 'set_clock_transition' constraints__

Code

```
# Converting set_clock_transition constraints
# -------------------------------------------
set find_keyword [lsearch -all -inline $lines "set_clock_transition*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_clocks"]+1}]]
        if {![string match $new_port_name $port_name]} {
		set new_port_name $port_name
		set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_clocks"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nslew $port_name $delay_value"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file
```
__Converting 'set_input_delay' constraints__

Processes 'set_input_transition' constraints part of SDC.

Code
```
# Converting set_input_delay constraints
# --------------------------------------
set find_keyword [lsearch -all -inline $lines "set_input_delay*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
		set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_ports"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nat $port_name $delay_value"
	}
}
close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file
```
__Converting 'set_input_transition' constraints__

Code

```
# Converting set_input_transition constraints
# -------------------------------------------
set find_keyword [lsearch -all -inline $lines "set_input_transition*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_ports"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nslew $port_name $delay_value"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file
```
__Converting set_output_delay constraints__

Processesing 'set_output_delay' constraints part of SDC.
Code
```
# Converting set_output_delay constraints
# ---------------------------------------
set find_keyword [lsearch -all -inline $lines "set_output_delay*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*"] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        		set port_index [lsearch $new_elem "get_ports"]
        		lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $tmp2_file "\nrat $port_name $delay_value"
	}
}

close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file [read $tmp2_file]
close $tmp2_file
```
__Converting set_load constraints__

With this, all SDC constarints are processed, so we close the /tmp/3 file containing all processed data for now.

Code
```
# Converting set_load constraints
# -------------------------------
set find_keyword [lsearch -all -inline $lines "set_load*"]
set tmp2_file [open /tmp/2 w]
set new_port_name ""
foreach elem $find_keyword {
        set port_name [lindex $elem [expr {[lsearch $elem "get_ports"]+1}]]
        if {![string match $new_port_name $port_name]} {
                set new_port_name $port_name
        	set delays_list [lsearch -all -inline $find_keyword [join [list "*" " " $port_name " " "*" ] ""]]
        	set delay_value ""
        	foreach new_elem $delays_list {
        	set port_index [lsearch $new_elem "get_ports"]
        	lappend delay_value [lindex $new_elem [expr {$port_index-1}]]
        	}
        	puts -nonewline $timing_file "\nload $port_name $delay_value"
	}
}
close $tmp2_file
set tmp2_file [open /tmp/2 r]
puts -nonewline $timing_file  [read $tmp2_file]
close $tmp2_file

# Closing tmp file after writing constraints converted from generated SDC
close $timing_file
```
<img width="765" alt="Screenshot 2023-11-10 174708" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/b9ec4073-d3ad-46c4-abb2-225f514eaaf5">

**Expanding the bussed input and output ports**

The /tmp/3 file contains bussed ports as <port_name>*, which is expanded to each bit, and single-bit port lines are untouched. This new content is dumped to .timing file, and then the proc exits by giving output the OpenTimer command to access this .timing file.

Code
```
# Expanding the bussed input and output ports to it's individual bits and writing final .timing file for OpenTimer
set ot_timing_file [open $sdc_dirname/$sdc_filename.timing w]
set timing_file [open /tmp/3 r]
while { [gets $timing_file line] != -1 } {
        if {[regexp -all -- {\*} $line]} {
                set bussed [lindex [lindex [split $line "*"] 0] 1]
                set final_synth_netlist [open $sdc_dirname/$sdc_filename.final.synth.v r]
                while { [gets $final_synth_netlist line2] != -1 } {
                        if {[regexp -all -- $bussed $line2] && [regexp -all -- {input} $line2] && ![string match "" $line]} {

                        	puts -nonewline $ot_timing_file "\n[lindex [lindex [split $line "*"] 0 ] 0 ] [lindex [lindex [split $line2 ";"] 0 ] 1 ] [lindex [split $line "*"] 1 ]"

                        } elseif {[regexp -all -- $bussed $line2] && [regexp -all -- {output} $line2] && ![string match "" $line]} {

                        	puts -nonewline $ot_timing_file "\n[lindex [lindex [split $line "*"] 0 ] 0 ] [lindex [lindex [split $line2 ";"] 0 ] 1 ] [lindex [split $line "*"] 1 ]"

                        }
                }
        } else {
        	puts -nonewline $ot_timing_file  "\n$line"
        }
}
close $timing_file
puts "set_timing_fpath $sdc_dirname/$sdc_filename.timing"

}
```
Config file after timing file is generated inside 

<img width="932" alt="Screenshot 2023-11-10 174515" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/69086079-c055-483e-9f75-3ef8112403c3">

After the bussed ports are expanded 

<img width="924" alt="Screenshot 2023-11-10 174532" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/79addadc-a2f9-4461-b7da-9d2e5392faf5">

**Preparation for rest of .conf file and .spef file for openTimer STA**

Below is the code to write .spef with the current date and time in the spef code and to append the rest of the portion of .conf file.

```
# Preparation of .conf & .spef for OpenTimer STA
# ----------------------------------------------
# Continue to write .conf and also write a .spef
# Writing .spef
set enable_prelayout_timing 1
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
set conf_file [open $OutputDirectory/$DesignName.conf a]
puts $conf_file "set_spef_fpath $OutputDirectory/$DesignName.spef"
puts $conf_file "init_timer "
puts $conf_file "report_timer "
puts $conf_file "report_wns "
puts $conf_file "report_worst_paths -numPaths 10000 "
close $conf_file
```
<img width="930" alt="Screenshot 2023-11-10 180701" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/a764e1a4-96c2-44bb-aabc-ed8745698b7e">

Conf file

<img width="928" alt="Screenshot 2023-11-10 180555" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/3f5bc14a-0c78-4221-beda-46f7abcdff76">

spef file

<img width="930" alt="Screenshot 2023-11-10 180630" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/79f11381-e9de-43cd-b473-9f4bb8edff70">

***STA using OpenTimer***

Code to run STA on OpenTimer and capture its runtime

```
# Static Timing Analysis using OpenTimer
# --------------------------------------
# Running STA on OpenTimer and dumping log to .results and capturing runtime
set tcl_precision 3
set time_elapsed_in_us [time {exec /home/kunalg/Desktop/tools/opentimer/OpenTimer-1.0.5/bin/OpenTimer < $OutputDirectory/$DesignName.conf >& $OutputDirectory/$DesignName.results}]
set time_elapsed_in_sec "[expr {[lindex $time_elapsed_in_us 0]/1000000}]sec"
puts "\nInfo: STA finished in $time_elapsed_in_sec seconds"
puts "\nInfo: Refer to $OutputDirectory/$DesignName.results for warnings and errors"
```
<img width="926" alt="Screenshot 2023-11-10 181912" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/3f413e68-6811-474f-afcb-2773028b4f0d">

<img width="834" alt="Screenshot 2023-11-10 182038" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/049976da-c394-46c4-99b6-1a9a890dde36">

Code to obtain WNS,FEP,Instance Count

```
# Find worst output violation
set worst_RAT_slack "-"
set report_file [open $Output_Directory/$Design_Name.results r]
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
set report_file [open $Output_Directory/$Design_Name.results r]
set count 0
while { [gets $report_file line] != -1 } {
	incr count [regexp -all -- $pattern $line]
}
set Number_output_violations $count
close $report_file

# Find worst setup violation
set worst_negative_setup_slack "-"
set report_file [open $Output_Directory/$Design_Name.results r]
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
set report_file [open $Output_Directory/$Design_Name.results r]
set count 0
while { [gets $report_file line] != -1 } {
	incr count [regexp -all -- $pattern $line]
}
set Number_of_setup_violations $count
close $report_file

# Find worst hold violation
set worst_negative_hold_slack "-"
set report_file [open $Output_Directory/$Design_Name.results r]
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
set report_file [open $Output_Directory/$Design_Name.results r]
set count 0
while {[gets $report_file line] != -1} {
	incr count [regexp -all - $pattern $line]
}
set Number_of_hold_violations $count
close $report_file

# Find number of instance
set pattern {Num of gates}
set report_file [open $Output_Directory/$Design_Name.results r]
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

```
<img width="924" alt="Screenshot 2023-11-10 183909" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/9ce5cd0f-94f7-4ae2-a062-cc658d5db535">

QoR Generation (Quality of results)

Code
```
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
```
<img width="910" alt="Screenshot 2023-11-10 184502" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/30095e08-c1fb-42e1-a92c-65aa701068ca">


**Acknowledgements**

[Kual Ghosh](https://github.com/kunalg123), Co-founder, VSD Corp.Pvt.Ltd
