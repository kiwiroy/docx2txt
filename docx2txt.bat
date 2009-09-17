@echo off

:: docx2txt, a command-line utility to convert Docx documents to text format.
:: Copyright (C) 2008-now Sandeep Kumar
::
:: This program is free software; you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation; either version 3 of the License, or
:: (at your option) any later version.
::
:: This program is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
:: GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program; if not, write to the Free Software
:: Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

::
:: A simple commandline .docx to .txt converter
::
:: This batch file is a wrapper around core docx2txt.pl script.
::
:: Author : Sandeep Kumar (shimple0 -AT- Yahoo .DOT. COM)
::
:: ChangeLog :
::
::    17/09/2009 - Initial version of this file. It has similar functionality
::                 as corresponding unix shell script.
::


::
:: Set paths to perl binary and docx2txt.pl script.
::

set PERL=C:\Program Files\strawberry-perl-5.10.0.6\perl\bin\perl.exe
:: set PERL=C:\Cygwin\bin\perl.exe

set DOCX2TXT_PL="docx2txt.pl"

::
:: If CAKECMD variable is set, batch file will unzip the content of argument
:: .docx file in a directory and pass that directory as the argument to the
:: docx2txt.pl script.
::

:: set CAKECMD=C:\Program Files\cake\CakeCmd.exe


::
:: Check if this batch file is invoked correctly.
::
if "%1" == "" goto USAGE
if not "%2" == "" goto USAGE
goto CHECK_ARG


:USAGE

echo.
echo Usage : "%0" file.docx
echo.
echo 	"file.docx" can also specify a directory holding the unzipped
echo 	content of a .docx file.
echo.
goto END


::
:: Check if argument specifies a directory or a file.
::

:CHECK_ARG

set INPARG=%1

if exist %1\nul (
    goto INP_IS_DIR
) else if not exist %1 (
    echo.
    echo Argument file/directory "%1" does not exist.
    echo.
    goto END
)

goto GENERATE_TXTFILE_NAME


::
:: Remove any trailing '\'s from input directory name.
::

:INP_IS_DIR

set LastChar=%INPARG:~-1%
if not "%LastChar%" == "\" goto GENERATE_TXTFILE_NAME
set INPARG=%INPARG:~0,-1%
goto INP_IS_DIR


:GENERATE_TXTFILE_NAME

set FILEEXT=%INPARG:~-5%
if "%FILEEXT%" == ".docx" goto EXT_IS_DOCX
set TXTFILE=%INPARG%.txt
goto CHECK_FOR_OVERWRITING


:EXT_IS_DOCX

set TXTFILE=%INPARG:~0,-5%.txt


::
:: Check whether output text file already exists, and whether user wants to
:: overwrite that.
::

:CHECK_FOR_OVERWRITING

if not exist %TXTFILE% goto NO_UNZIP

echo.
echo Output file %TXTFILE% already exists.
set /P confirm=Overwrite %TXTFILE% [Y/N] ?

if /I "%confirm%" == "N" (
    echo.
    echo Please copy %TXTFILE% somewhere else and rerun this batch file.
    echo.
    goto END
)


::
:: Since docx2txt.pl script expects an unzipper that can send the extracted
:: file to stdout. If CakeCmd.exe is being used as unzipper, then extract the
:: contents into a directory and pass that directory as the argument to the
:: perl script.
::

:NO_UNZIP

if exist %1\nul goto CONVERT

if not defined CAKECMD goto CONVERT
echo here
rename %1 %1.zip
echo y | "%CAKECMD%" extract "%1.zip" \ "%1" > nul
set RENAMEBACK=yes


::
:: Invoke docx2txt.pl perl script to do the actual text extraction
::

:CONVERT

"%PERL%" "%DOCX2TXT_PL%" "%INPARG%" "%TXTFILE%" 

if %ERRORLEVEL% == 2 (
    echo.
    echo Failed to extract text from %1!
    echo.
) else if %ERRORLEVEL% == 0 (
    echo.
    echo Text extracted from "%1" is available in "%TXTFILE%".
    echo.
)


:END

if defined RENAMEBACK (
    rmdir /S /Q %1
    rename %1.zip %1
)

set PERL=
set DOCX2TXT_PL=
set CAKECMD=

set FILEEXT=
set INPARG=
set TXTFILE=
set RENAMEBACK=
set confirm=
