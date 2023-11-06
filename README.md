
# TCL_Workshop
A unique User-Interface that will take RTL Netlist and SDC Constraints as input and will generate synthesized netlist and pre-layout timing report as output using TCL Programming.
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




