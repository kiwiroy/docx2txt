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
#    15/08/2008 - Invoking docx2txt.pl with docx document instead of xml file,
#                 so don't need unzip and rm actions now.
#


SED=/usr/bin/sed

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
check_for_executable "$SED"
[ $xcheck -ne 0 ] && exit 1


TEXTFILE=`echo "$1" | $SED 's/\.docx$//'`
[ -z "$TEXTFILE" ] && TEXTFILE="$1" 
TEXTFILE="$TEXTFILE.txt"


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
check_for_existence "$TEXTFILE" "Output text file"
[ $echeck -ne 0 ] && exit 1

#
# Invoke perl script to do the actual text extraction
#

"$MYLOC/docx2txt.pl" "$1" "$TEXTFILE"
if [ $? == 0 ]
then
    echo "Text extracted from <$1> is available in <$TEXTFILE>."
else
    echo "Failed to extract text from <$1>!"
fi

