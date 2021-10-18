# Windows-RoboCopy-Batch
 
RoboCopy Batch is a simple batch script frontend to RoboCopy.

The application uses a RoboCopy jobfile named "robocopy.rcj" which must be in the same directory as the application itself. This jobfile contains all options that are given to
RoboCopy. The first two rows of the jobfile must contain the following:
*  /NOSD
*  /NODD

A default RoboCopy jobfile has been added to the distribution.

When starting RoboCopy command from the commandline the application makes a directory in the destination folder that which is equal to the source folder name. If this folder already exists files within it may be overwritten.

Also the application makes a log which has the following name: <systemdate/time>_<source folder name>.log. The log is saved in a sub-directory of the application named /log.

# Total Commander
This application can be used in conjunction with Total Commander. 

Add a button to the buttonbar (via change button bar) with the following parameters:
|Parameter|Value|
|---------|-----|
|Command    | \<path-to-robocopy-batch\>\\RoboCopy.bat|
|Parameters | %p %t |
|Start path | \<path-to-robocopy-batch\>\\ |
|Icon file  | \<path-to-total-commander\>\\TOTALCMD64.EXE|
|Icon       | \<icon-of-choice\>|
|Tooltip    | RoboCopy|

# Prerequisites
The follwing applications must be installed and runable from the commandline:
* RoboCopy 
* Powershell
 
The distribution was specificly made for Windows 7.

# Installation
Download all files to a location on your machine. Double click 'RoboCopy.bat' or run it form the commandline (CMD).

# Support
As  my time is extremly limited I can offer no support what-so-ever.
