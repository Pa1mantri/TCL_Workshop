
# TCL_Workshop
A unique User-Interface that will take RTL Netlist and SDC Constraints as input and will generate synthesized netlist and pre-layout timing report as output using TCL Programming.
# TCL Scripting

Using TCL Scripting, here we will convert the data present in the .csv file( excel kind of file, where data is represented and separated by commas, in libreoffice it is represented in tabular form) into a data sheet.

<img width="930" alt="Screenshot 2023-11-01 113352" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/fa9fa4ab-a614-46a0-a6ed-63775739f1b3">

All the files that are present in the above file are sourced from vsdsynth folder.

<img width="629" alt="Screenshot 2023-11-01 114439" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/af8e158e-78a1-490e-bf7b-b1e21f1cfd52">


The process converting this .csv file data into data sheet using TCL script is divided into three sub-tasks.

1. Create command named “vsdsynth” which takes the .csv file and passes the .csv file to TCL script.
2. Convert all the inputs in the .csv file into two different formats. One is format1 and the other is sdc format.
    
 <img width="863" alt="Screenshot 2023-11-01 115834" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/4426f053-85b5-4ebe-a720-eeded7cff8a8">

 The above image shows how format[1] looks. Since the format1 information has to be passed to yosys tool, it has to be presented in a way that is understood by yosys.
    
 Similarly there is another file openMSP430_design_constraints_csv files which looks like the image below 
    
 <img width="930" alt="Screenshot 2023-11-01 120111" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/a80dd716-35dd-4d77-9eb4-c54520330cbe">

 <img width="960" alt="Screenshot 2023-11-01 120342" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/390ec9f5-81d4-475b-882a-08ab1c934d0b">
     
 This has to be converted into SDC (Synopsys Design Constraint) format. SDC format is a standard representation across the industry, acceptable to all the CAD tools. This 
 conversion also happens using TCL Script. This is the second sub-task apart from creating a command(i.e. 1st sub-task)
    
3. Next Sub-task is to convert this format[1] data & SDC data into different format i.e. format2 and pass it to timing tool “**Opentimer**”. opentimer accepts command in this fashion
    
    <img width="424" alt="Screenshot 2023-11-01 121238" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/340fd6af-7973-4c6d-b8d5-cf41fbbf9ba4">

    
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

<img width="420" alt="Screenshot 2023-11-02 161312" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/25960da2-009e-497a-89ee-c85021e56379">

After auto creating all the variables, this is how it should be

<img width="864" alt="Screenshot 2023-11-02 163204" src="https://github.com/Pa1mantri/TCL_Workshop/assets/114488271/29fc46c0-3a9b-4569-80e0-0de6ecb6209f">

In a similar way how we convert the design_details.csv file into a matrix and, we perform the same action to the constraints.csv file.

After finding the row numbers from which input , output and clock port starts. First start the script by processing the clock constraints in the csv file.

![Screenshot 2023-11-04 111746.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/2a93c1a9-af21-459a-9f69-6f78e913144b/632b6a85-8dbf-4cb5-90c0-0635fbea27b7/Screenshot_2023-11-04_111746.png)

TCL script for processing clock constraints

![Screenshot 2023-11-04 190457.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/2a93c1a9-af21-459a-9f69-6f78e913144b/e15468dd-58a9-48e7-9915-c4c799f384a1/Screenshot_2023-11-04_190457.png)

![Screenshot 2023-11-04 190513.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/2a93c1a9-af21-459a-9f69-6f78e913144b/05907427-d90c-45c6-8207-64622fba25ec/Screenshot_2023-11-04_190513.png)

The SDC file generated in the output directory after reading the values from the csv file

![Screenshot 2023-11-04 190423.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/2a93c1a9-af21-459a-9f69-6f78e913144b/fcc515d7-2ce2-46fd-86f0-a24e2cd207f0/Screenshot_2023-11-04_190423.png)

**Processing input constraints**

**set netlist [glob -dir $NetlistDirectory *.v]**  This command helps in getting all the .v files inside the NetlistDirectory. We can access all these files using $netlist variable.

**set tmp_file [open /tmp/1 w]**  Opening a temporary file in write mode.

SDC file after input constraints are added into file through TCL script

![Screenshot 2023-11-05 184741.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/2a93c1a9-af21-459a-9f69-6f78e913144b/886a10ff-31f6-4a3a-acde-a4b7f257bd87/Screenshot_2023-11-05_184741.png)

After searching the SDC file using grep command, to check the bussed signals, which are represented using *.

![Screenshot 2023-11-05 184635.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/2a93c1a9-af21-459a-9f69-6f78e913144b/a484a0da-a384-41f4-ba76-664a2ca94c39/Screenshot_2023-11-05_184635.png)



