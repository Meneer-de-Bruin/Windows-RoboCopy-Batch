@echo off
@setlocal enableextensions enabledelayedexpansion
cls

rem *** RoboCopy.bat ***
rem Copyright : 2021 Koninklijke Bibliotheek
rem License   : MIT
rem Date      : 12-10-2021 
rem Version   : 0.9

rem Can be used in TotalCommander - with change button bar.
rem Command    : <path-to-robocopy-batch>\RoboCopy.bat
rem Parameters : %p %t 
rem Start path : <path-to-robocopy-batch>\
rem Icon file  : <path-to-total-commander>\TOTALCMD64.EXE
rem Icon       : <icon-of-choice>
rem Tooltip    : RoboCopy

rem Can be used as standalone batch file. Start the batch after changing (cd "<path-to-robocopy-batch>") to the directory.

rem Prerequisites
rem In order to be able to run this batch script it needs access to:
rem Robocopy (duh)
rem Powershell

rem ***************************************************************************************
rem *** defaults                                                                        ***
rem ***************************************************************************************
set _version=0.9

rem switch for verification for testing purposes (1). Default: 0
set _verification=0

rem location of batch
set _mypath=%~dp0

rem location of robocopy jobfile relative to bat
set _rcj_loc=%_mypath%robocopy.rcj

rem ***************************************************************************************
rem *** check input parameters                                                          ***
rem ***************************************************************************************
rem maximum of 2
rem count number of parameters
set /a _count_p=0
for %%p in (%*) do (
	if not [%%~p] == [] (
		set /a _count_p+=1
	)
)

rem check number of parameters
if %_count_p% GTR 2 (
	echo FOUT: Meer dan twee parameters gegeven.
	echo INPUT: %*
	echo PARAMETERS:
	
	set /a _count_p=0
	for %%p in (%*) do (
		set /a _count_p+=1
		echo !_count_p!	%%p
	)
	
	goto :usage
)

rem check if parameter /?
if /i [%1] == [/?] (
	goto :usage
)

goto :start_batch
 
rem ***************************************************************************************
rem *** usage                                                                        ***
rem ***************************************************************************************
:usage
echo.
echo RoboCopy.bat - Kopieren van folders naar gewenste locatie m.b.v. robocopy.exe.
echo.
echo Versie: %_version%
echo.
echo Gebruik:
echo   RoboCopy.bat "<src>"
echo   RoboCopy.bat "<src>" "<dst>"
echo   RoboCopy.bat /?
echo.
echo Opties:
echo   "<src>" - Bron folder om te kopieren. 
echo   "<dst>" - Doel folder om naar te kopieren.
echo.
echo "<src>" en "<dst>" moeten uiteraard van elkaar verschillen. "<dst>" mag ook geen onderdeel zijn van "<src>".

goto :exit_robocopy

rem ***************************************************************************************
rem *** start batch                                                                     ***
rem ***************************************************************************************
:start_batch

rem ***************************************************************************************
rem *** get input folder                                                                ***
rem *************************************************************************************** 
echo ROBOCOPY %_version%

rem check if src was given as parameter
if not [%~1] == [] (
	set _src="%~1"
	goto :proces_src
)

echo.
set /p _src="Wat is de bron folder? "

:proces_src
rem could be input from parameter so ...
shift

rem remove quotes
set _src=%_src:"=%
set _src=%_src:'=%

rem strip trailing \
if ["%_src:~-1%"] == ["\"] (
	set _src=%_src:~0,-1%
)

rem get the long path name (if sortend version is given)
for /f "usebackq delims=" %%f in (
  `powershell.exe -Command "(Get-Item '%_src%').FullName"`
) do @set "_src=%%~f"

rem get last part of path as batch name
for %%f in ("%_src%") do set _batchName=%%~nxf

rem ***************************************************************************************
rem *** get output folder                                                               ***
rem ***************************************************************************************
rem check if dst was given as parameter
if not [%~1] == [] (
	set _dst="%~1"
	goto :proces_dst
)

echo.
set /p _dst="Wat is de doel folder? "

:proces_dst
rem could be input from parameter so ...
shift

rem remove quotes
set _dst=%_dst:"=%
set _dst=%_dst:'=%

rem strip trailing \
if [%_dst:~-1%] == [\] (
	set _dst=%_dst:~0,-1%
)

rem get the long path name (if sortend version is given)
for /f "usebackq delims=" %%f in (
  `powershell.exe -Command "(Get-Item '%_dst%').FullName"`
) do @set "_dst=%%~f"

rem ***************************************************************************************
rem *** Verify SRC and DST                                                            ***
rem ***************************************************************************************
echo.
echo Bron: %_src% 
echo Doel: %_dst%

set /p _check="Klopt dit [y|N]"?

if /i not "%_check:~,1%" == "y" (
	echo RoboCopy wordt niet gestart.
	goto :exit_robocopy
)

rem ***************************************************************************************
rem *** checks on input                                                                 ***
rem ***************************************************************************************
rem CHECK if _src is indeed an existing folder
cd "%_src%" >NUL 2>&1
if %errorlevel% GTR 0 (
	echo FOUT: Folder bestaat niet.
	echo %_src%
	goto :exit_robocopy
)

rem CHECK if _dst is a folder
cd %_dst% >NUL 2>&1
if %errorlevel% GTR 0 (
	echo FOUT: Folder bestaat niet.
    echo %_dst%
    goto :exit_robocopy	
)

rem CHECK if src is not part of dst
echo."%_dst%" | findstr /I /L /C:"%_src%"

if %errorlevel% EQU 0 (
	echo FOUT: Doel kan geen onderdeel vormen van bron.
	echo Bron: %_src%
	echo Doel: %_dst%
	goto :exit_robocopy
)

rem add batchname to dst folder path
set _dst=%_dst%\%_batchName%

rem CHECK id dst not equal to src
if [%_dst%] == [%_src%] (
	echo FOUT: Bron en Doel kunnen niet gelijk zijn.
	echo Bron: %_src%
	echo Doel: %_dst%
	goto :exit_robocopy
)

rem CHECK if dst exists (if so warn)
cd "%_dst%" >NUL 2>&1
if %errorlevel% EQU 0 (
	echo.
	echo WAARSCHUWING: Doel batch folder bestaat al.
	echo %_dst%
	set /p _check="Klopt dit [Y|n]"?

	if /i "%_check:~,1%" == "n" (
		goto :exit_robocopy
	)
)

rem ***************************************************************************************
rem *** determine logfile                                                               ***
rem ***************************************************************************************
rem make timestamp
set _timestamp=%DATE:~6,4%%DATE:~3,2%%DATE:~0,2%%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
set _timestamp=%_timestamp: =0%

rem logfile name is last part of _src
set _log_path=%_mypath%log\

rem check if log path exists or create it (actually just create it)
md "%_log_path%" >NUL 2>&1

rem make log file path/name
set _log_base=%_log_path%%_batchName%_%_timestamp%
set _log=%_log_base%.log

rem ***************************************************************************************
rem *** generate command                                                                ***
rem ***************************************************************************************
set _cmd=robocopy.exe /LOG:"%_log%" /JOB:"%_rcj_loc%" "%_src%" "%_dst%"

rem ***************************************************************************************
rem *** show command and verify                                                         ***
rem ***************************************************************************************
if %_verification% NEQ 1 (
	goto :exec_robocopy
)

echo.
echo VERIFICATIE
echo Het volgende RoboCopy commando wordt uitgevoerd:
echo %_cmd%
echo.
set /p _check="Klopt dit [y|N]"?

if /i not "%_check:~,1%" == "y" (
	echo RoboCopy wordt niet gestart.
	goto :exit_robocopy
)

rem ****************************************************************************************
rem *** execute robocopy command                                                         ***
rem ****************************************************************************************
:exec_robocopy

rem copy jobfile to log directory
copy "%_rcj_loc%" "%_log_base%.rcj" >NUL 2>&1

rem finally start robocopy in seperate cmd window
rem this way many robocopy jobs can be started
start "Robocopy" /min %_cmd% &

echo.
echo RoboCopy gestart.
echo BATCH : %_batchName%
echo LOG   : %_log%

rem ***************************************************************************************
rem *** close batch                                                             ***
rem ***************************************************************************************
:exit_robocopy

echo.
echo Druk een toets om te sluiten ...
pause >NUL

endlocal