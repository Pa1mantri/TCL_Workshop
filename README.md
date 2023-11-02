
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
     
    This has to be converted into SDC (Synopsys Design Constraint) format. SDC format is a standard representation across the industry, acceptable to all the CAD tools. This conversion also happens using TCL Script. This is the second sub-task apart from creating a command(i.e. 1st sub-task)
    
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

![Screenshot 2023-11-02 144130.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/2a93c1a9-af21-459a-9f69-6f78e913144b/6454ab7d-1f39-4f52-9796-24c9d662c201/Screenshot_2023-11-02_144130.png)

Command to create a matrix object with matrix name m is **struct :: matrix m**

**set f [open $filename] :  [open $filename]** will open a file in read mode and that particular instruction is stored in the variable f. If we want to do any processing to the csv file(like counting the number of rows, columns) first step is to open the file in read mode. $f variable will help us do any processing on the file.

**csv :: read2matrix $f m, auto**  Convert the file($f) which is in open(read) mode into a matrix, use the comma as the separator to form different cells in the matrix, auto command will automatically identifies the size of the matrix.

![Screenshot 2023-11-02 151748.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/2a93c1a9-af21-459a-9f69-6f78e913144b/f0741813-64a7-41e9-a0d3-632271e89629/Screenshot_2023-11-02_151748.png)

**close $f :**Since all the information of the csv files is now included in the matrix, we can close the file.

**set columns [m columns]** will return the number of columns in the matrix above. Auto command already identified the number the rows and columns in the above step. Having a variable to address the number of columns is an advantage. we can use it variable further. Similarly for rows,               **set num_of_rows [m rows]** will gives the value of no of rows in the matrix.

**m link my_arr**  Convert the matrix into an array

Now we will run a loop which will set the design name to OpenMSP430 and all the other variables to the respective paths. In the matrix form, they all are independent entities. We will correlate each one with the respective paths.

![Screenshot 2023-11-02 154915.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/2a93c1a9-af21-459a-9f69-6f78e913144b/c2b4cc23-460e-4e48-8aac-c80342220838/Screenshot_2023-11-02_154915.png)

Info: Setting Design name as ‘OpenMSP_430’

![Screenshot 2023-11-02 160043.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/2a93c1a9-af21-459a-9f69-6f78e913144b/a3b945f4-77f0-40a5-8603-13c152007000/Screenshot_2023-11-02_160043.png)

Here first variable is set. i.e. DesignName variable is set to $my_arr(1,0);  string map helps in removing the space between the Design Name. After this step **$DesignName = openMSP_430**

**file normalize** will remove the tilda(~) and replace with the absolute path

![Screenshot 2023-11-02 161312.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/2a93c1a9-af21-459a-9f69-6f78e913144b/2ad8e708-dce3-4106-a932-150f1a087381/Screenshot_2023-11-02_161312.png)

After auto creating all the variables, this is how it should be

![Screenshot 2023-11-02 163204.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/2a93c1a9-af21-459a-9f69-6f78e913144b/c42aeacb-f9f1-4336-b978-a057cfccab30/Screenshot_2023-11-02_163204.png)

**Checking if directories and files in csv file exists or not** We need to check whether the file paths mentioned in the csv file (output directory, netlist directory) and files inside exists or not, otherwise vsdsynth.tcl flow breaks.

**Reading constraints file and converting it to  SDC format** SDC is a standard Synopsys Design Constraint format. We need to convert this so that it can be used in the future by the PNR tool or STA tool.

[Take Aways](https://www.notion.so/Take-Aways-81130c12bbf8419fbf62804fa3acb579?pvs=21)
