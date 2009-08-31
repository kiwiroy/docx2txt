#!/usr/bin/env perl

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
# Perl v5.8.2 was used for testing this script.
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
#    03/09/2008 - Fixed the slip in usage message.
#    12/09/2008 - Slightly changed the script invocation and argument handling
#                 to incorporate some of the shell script functionality here.
#                 Added support to handle embedded urls in docx document.
#    23/09/2008 - Changed #! line to use /usr/bin/env - good suggestion from
#                 Rene Maroufi (info>AT<maroufi>DOT<net) to reduce user work
#                 during installation.
#    31/08/2009 - Added support for handling more escape characters.
#                 Using OS specific null device to redirect stderr.
#                 Saving text file in binary mode.
#


#
# Adjust the settings here.
#

my $unzip = "/usr/bin/unzip";  # Windows path like "C:\\path\\to\\unzip.exe"
my $nl = "\n";		# Alternative is "\r\n".
my $lindent = "  ";	# Indent nested lists by "\t", " " etc.
my $lwidth = 80;	# Line width, used for short line justification.

# ToDo: Better list handling. Currently assumed 8 level nesting.
my @levchar = ('*', '+', 'o', '-', '**', '++', 'oo', '--');


# Only amp, gt and lt are required for docx escapes, others are used for better
# text experience.
my %escChrs = (	amp => '&', gt => '>', lt => '<',
		acute => '\'', brvbar => '|', copy => '(C)', divide => '/',
		laquo => '<<', macr => '-', nbsp => ' ', raquo => '>>',
		reg => '(R)', shy => '-', times => 'x'
);


#
# Check argument(s) sanity.
#

my $usage = <<USAGE;

Usage:	$0 <infile.docx> [outfile.txt|-]

	Use '-' as the outfile name to dump the text on STDOUT.
	Output is saved in infile.txt if second argument is omitted.

USAGE

die $usage if (@ARGV == 0 || @ARGV > 2);

stat($ARGV[0]);
die "Can't read docx file <$ARGV[0]>!\n" if ! (-f _ && -r _);
die "<$ARGV[0]> does not seem to be docx file!\n" if -T _;


#
# Extract needed data from argument docx file.
#

if ($ENV{OS} =~ /^Windows/) {
    $nulldevice = "nul";
} else {
    $nulldevice = "/dev/null";
}

my $content = `$unzip -p '$ARGV[0]' word/document.xml 2>$nulldevice`;
die "Failed to extract required information from <$ARGV[0]>!\n" if ! $content;


#
# Be ready for outputting the extracted text contents.
#

if (@ARGV == 1) {
     $ARGV[1] = $ARGV[0];
     $ARGV[1] .= ".txt" if !($ARGV[1] =~ s/\.docx$/\.txt/);
}

my $txtfile;
open($txtfile, "> $ARGV[1]") || die "Can't create <$ARGV[1]> for output!\n";


#
# Gather information about header, footer, hyperlinks, images, footnotes etc.
#

$_ = `$unzip -p '$ARGV[0]' word/_rels/document.xml.rels 2>$nulldevice`;

my %docurels;
while (/<Relationship Id="(.*?)" Type=".*?\/([^\/]*?)" Target="(.*?)"( .*?)?\/>/g)
{
    $docurels{"$2:$1"} = $3;
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
# Subroutines for dealing with embedded links and images
#

sub hyperlink {
    return "{$_[1]}[HYPERLINK: $docurels{\"hyperlink:$_[0]\"}]";
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

$content =~ s{<w:hyperlink r:id="(.*?)".*?>(.*?)</w:hyperlink>}/hyperlink($1,$2)/oge;

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

#
# Convert docx specific escape chars first.
#
$content =~ s/(&)(amp|gt|lt)(;)/$escChrs{lc $2}/ig;

#
# Another pass for a better text experience, after sequences like "&amp;laquo;"
# are converted to "&laquo;".
#
$content =~ s/(&)([a-zA-Z]+)(;)/($escChrs{lc $2} ? $escChrs{lc $2} : '&'.$2.';')/ge;


#
# Write the extracted and converted text contents to output.
#

binmode $txtfile;    # Ensure no auto-conversion of '\n' to '\r\n' on Windows.
print $txtfile $content;
close $txtfile;

