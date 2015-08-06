#!/bin/bash

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

echo "hello"
#gs -sDEVICE=txtwrite -dTextFormat=0 -o out.txt in.pdf

awk '
BEGIN { FS="[\" ]"; isBold = 0 }
$0~"Bold" {isBold = 1}
$0~"<span" { if( !isBold ) { printf "%s ", $3; FS = "\""}}
$0~"<char" { if( !isBold ) {printf $4}}
$0~"</span" { if( !isBold ) {print ""}; FS = "[\" ]"; isBold = 0}
' out.txt > fields.html

echo "made fields"

php -r 'while(($line=fgets(STDIN)) !== FALSE) echo html_entity_decode($line, ENT_QUOTES|ENT_HTML5);' < fields.html > fields.txt


awk '
BEGIN {start=""; end=""; loc=""; price=""; skip=0;}
$0~"^30 Location" { 
    printf "%s \t %s \t %s \t %s \t", start, end, price, loc;
    gsub(" ", "+", loc); system("./lookup.sh \""loc"\""); 
    start=""; end=""; loc=""; price="";
    skip=0; next;
}
{if (skip) {next}}

$0~"^105 partir" {start=$4; end=$6}
$0~"^305 fr." {price=$2}

$0~"^30 Remarques" {skip=1; next}
$0~"^30 Publication" {next}

$0~"^30 Université de Lausanne" {next}
$0~"^30 Service des affaires socio-culturelles" {next}
$0~"^30 Bâtiment Unicentre" {next}
$0~"^30 CH - 1015 Lausanne" {next}
$0~"^30 Offres de logement" {next}
$0~"^30 " {sub("30", "", $0); loc = loc " " $0 }
' fields.txt > data.txt

echo "rearranged into data"
