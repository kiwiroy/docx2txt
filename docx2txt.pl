#!/usr/bin/perl

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
# This script extracts text from document.xml contained inside .docx file.
#
# Author : Sandeep Kumar (shimple0 -AT- Yahoo .DOT. COM)
#
# ChangeLog :
#
#	10/08/2008 - Initial version (v0.1)
#


#
# Settings
#

my $nl = "\n";		# Alternative is "\r\n".
my $lindent = "  ";	# Indent nested lists by "\t", " " etc.

# ToDo: Better list handling. Currently assumed 8 level nesting.
my @levchar = ('*', '+', 'o', '-', '**', '++', 'oo', '--');

sub readfile {
    local $/ = undef;

    open my $fh, $_[0];
    my $readfile = <$fh>;
    return $readfile;
}

my $content = readfile("$ARGV[0]");

$content =~ s/<?xml .*?\?>(\r)?\n//;

$content =~ s{<w:p [^/>]+?/>|</w:p>}|$nl|og;
$content =~ s|<w:br/>|$nl|og;
$content =~ s|<w:tab/>|\t|og;

my $hr = '-' x 78 . $nl;
$content =~ s|<w:pBdr>.*?</w:pBdr>|$hr|og;

$content =~ s|<w:numPr><w:ilvl w:val="([0-9]+)"/>|$lindent x $1 . "$levchar[$1] "|oge;

#
# Uncomment either of below two lines and comment above line, if dealing
# with more than 8 level nested lists.
#

# $content =~ s|<w:numPr><w:ilvl w:val="([0-9]+)"/>|$lindent x $1 . '* '|oge;
# $content =~ s|<w:numPr><w:ilvl w:val="([0-9]+)"/>|'*' x ($1+1) . ' '|oge;

$content =~ s{<w:caps/>.*?(<w:t>|<w:t [^>]+>)(.*?)</w:t>}/uc $2/oge;

$content =~ s/<.*?>//g;


#
# Convert non-ASCII characters/character sequences to ASCII characters.
#

# $content =~ s/\xE2\x82\xAC/\xC8/og;	# euro symbol as saved by MSOffice
$content =~ s/\xE2\x82\xAC/E/og;	# euro symbol expressed as E

$content =~ s/\xE2\x80\xA6/.../og;
$content =~ s/\xE2\x80\xA2/::/og;	# four dot diamond symbol
$content =~ s/\xE2\x80\x9C/"/og;
$content =~ s/\xE2\x80\x99/'/og;
$content =~ s/\xE2\x80\x98/'/og;
$content =~ s/\xE2\x80\x93/-/og;

$content =~ s/\xC2\xA0//og;

$content =~ s/&amp;/&/ogi;
$content =~ s/&lt;/</ogi;
$content =~ s/&gt;/>/ogi;

print $content;

