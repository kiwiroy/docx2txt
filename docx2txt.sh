#!/bin/bash

# docx2txt, a command-line utility to convert Docx documents to text format.
# Copyright (C) 2008 Sandeep Kumar
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

#
# A simple .docx to text converter
#
# Saves output in filename.txt if argument filename ends in .docx (except for
# the case ".docx"), otherwise appends ".txt" to argument for the output
# filename.
#
# Author : Sandeep Kumar (shimple0 -AT- Yahoo .DOT. COM)
#
# ChangeLog :
#
#    10/08/2008 - Initial version (v0.1)
#


UNZIP=/usr/bin/unzip
SED=/usr/bin/sed
RM=/usr/bin/rm
RMFLAGS="-i"		# change to -f, when you are comfortable.

MYLOC=`dirname "$0"`	# invoked perl script docx2txt.pl is expected here.

function usage ()
{
    echo -e "\nUsage : $0 <file.docx>\n"
    exit 1
}

[ $# != 1 ] && usage

if ! [ -f "$1" -o -r "$1" ]
then
    echo -e "\nCan't read input file <$1>!"
    exit 1
fi


#
# $1 : path to executable
#
function check_for_executable ()
{
    if [ ! -x "$1" ]
    then
        echo -e "Check if <$1> exists and is executable!"
        xcheck=1
    fi
}

xcheck=0
check_for_executable "$UNZIP"
check_for_executable "$SED"
check_for_executable "$RM"
[ $xcheck -ne 0 ] && exit 1


TEXTFILE=`echo "$1" | $SED 's/\.docx$//'`
[ -z "$TEXTFILE" ] && TEXTFILE="$1" 
TEXTFILE="$TEXTFILE.txt"

XMLFILE="word/document.xml"

#
# $1 : filename to check for existence
# $2 : message regarding file
#
function check_for_existence ()
{
    if [ -f "$1" ]
    then
        read -p "overwrite $2 <$1> [y/n] ? " yn
        if [ "$yn" != "y" ]
        then
            echo -e "\nPlease copy <$1> somewhere before running the script.\n"
            echeck=1
        fi
    fi
}

echeck=0
check_for_existence "$XMLFILE"  "Extracted XML file"
check_for_existence "$TEXTFILE" "Output text file"
[ $echeck -ne 0 ] && exit 1

if [ -d word ]
then
    created=0
else
    created=1
fi

# echo "y" | "$UNZIP" -x "$1" "$XMLFILE" >/dev/null
echo "y" | "$UNZIP" -x "$1" "$XMLFILE" >/dev/null 2>/dev/null
"$MYLOC/docx2txt.pl" "$XMLFILE" > "$TEXTFILE"

echo -e "\nExtracted text from <$1> is available in <$TEXTFILE>\n"

if [ $created -eq 1 ]
then
    $RM $RMFLAGS -r word
else
    $RM $RMFLAGS "$XMLFILE"
fi

