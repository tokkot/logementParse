#!/bin/bash

echo "hello"
#gs -sDEVICE=txtwrite -dTextFormat=0 -o out.txt in.pdf

awk '
BEGIN { FS="[\" ]"; isBold = 0 }
$0~"Bold" {isBold = 1}
$0~"<span" { if( !isBold ) { printf "%s ", $3; FS = "\""}}
$0~"<char" { if( !isBold ) {printf $4}}
$0~"</span" { if( !isBold ) {print ""}; FS = "[\" ]"; isBold = 0}
' out.txt > fields.html


awk '
BEGIN {start=""; end=""; loc=""; price=""; skip=0}
$0~"30 Offres de logement" {skip=0;next}
$0~"30 Location" { 
printf "%s \t %s \t %s \t %s", start, end, price, loc; 
print " &#10;";
 start=""; end=""; loc=""; price=""; skip=0
next }
{if (skip) {next}}
$0~"105 partir" {start=$4; end=$6}
$0~"305 fr." {price=$2}

$0~"30 Remarques" {skip=1;next}
$0~"30 Publication" {next}
$0~"30 Universit&#xe9; de Lausanne" {skip=1;next}


$0~"30 " {sub("30", "", $0); loc = loc " " $0 }
END {}
' fields.html > data.html

perl -MHTML::Entities -alne 'print decode_entities($_)' data.html > data.txt

awk '
BEGIN {FS = "\t"}
{gsub(" ", "+", $4); system("echo \""$4"\"")}
' data.txt > lookups.txt






#curl "https://maps.googleapis.com/maps/api/distancematrix/json?origins=Sallaz-Chailly+1012+Lausanne&destinations=46.522035,6.565942&mode=transit&arrival_time=1441090800&key=AIzaSyCdyOjHwORvCZQObAKnvthOQaW1FG6YZjg"

#curl "https://maps.googleapis.com/maps/api/distancematrix/json?origins=+++Chemin+de+la+Lisière+3++1018+Lausanne+;&destinations=46.522035,6.565942&mode=transit&arrival_time=1441090800&key=AIzaSyCdyOjHwORvCZQObAKnvthOQaW1FG6YZjg"
