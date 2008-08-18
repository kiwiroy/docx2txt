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
#    10/08/2008 - Initial version (v0.1)
#    15/08/2008 - Script takes two arguments [second optional] now and can be
#                 used independently to extract text from docx file. It accepts
#                 docx file directly, instead of xml file.
#    18/08/2008 - Added support for center and right justification of text that
#                 fits in a line 80 characters wide (adjustable).
#


#
# Adjust the settings here.
#

my $unzip = "/usr/bin/unzip";
my $nl = "\n";		# Alternative is "\r\n".
my $lindent = "  ";	# Indent nested lists by "\t", " " etc.
my $lwidth = 80;	# Line width, used for short line justification.

# ToDo: Better list handling. Currently assumed 8 level nesting.
my @levchar = ('*', '+', 'o', '-', '**', '++', 'oo', '--');


#
# Check argument(s) sanity.
#

(@ARGV == 1 || @ARGV == 2) || die "Usage: $ARGV <infile.docx> [outfile.txt]\n";

stat($ARGV[0]);
die "Can't read docx file <$ARGV[0]>!\n" if ! (-f _ && -r _);
die "<$ARGV[0]> does not seem to be docx file!\n" if -T _;


#
# Extract needed data from argument docx file.
#

my $content = `$unzip -p '$ARGV[0]' word/document.xml 2>/dev/null`;
die "Failed to extract required information from <$ARGV[0]>!\n" if ! $content;


#
# Be ready for outputting the extracted text contents.
#

my $txtfile;
if (@ARGV == 1) {
    $txtfile = \*STDOUT;
} else {
    open($txtfile, "> $ARGV[1]") || die "Can't create <$ARGV[1]> for output!\n";
}


#
# Subroutines for center and right justification of text in a line.
#

sub cjustify {
	my $len = length $_[0];

	if ($len < ($lwidth - 1)) {
		my $lsp = ($lwidth - $len) / 2;
		return ' ' x $lsp . $_[0];
	} else {
		return $_[0];
	}
}

sub rjustify {
	my $len = length $_[0];

	if ($len < $lwidth) {
		return ' ' x ($lwidth - $len) . $_[0];
	} else {
		return $_[0];
	}
}


#
# Text extraction starts.
#

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

$content =~ s{<w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:t>(.*?)</w:t></w:r>}/cjustify($1)/oge;

$content =~ s{<w:pPr><w:jc w:val="right"/></w:pPr><w:r><w:t>(.*?)</w:t></w:r>}/rjustify($1)/oge;

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


#
# Write the extracted and converted text contents to output.
#

print $txtfile $content;
close $txtfile;

