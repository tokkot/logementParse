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

awk '
BEGIN {start=""; end=""; loc=""; price=""; skip=0}
$0~"^30 Location" { 
  if (length(price)>0) {
    printf "%s \t %s \t %s \t %s", start, end, price, loc; 
    print "";
    start=""; end=""; loc=""; price="" 
  }
  skip=0; next }

{if (skip) {next}}

$0~"^105 partir" {start=$4; end=$6}
$0~"^305 fr." {price=$2}

$0~"^30 Remarques" {skip=1; next}
$0~"^30 Publication" {next}

$0~"^30 Universit&#xe9; de Lausanne" {next}
$0~"^30 Service des affaires socio-culturelles" {next}
$0~"^30 B&#xe2;timent Unicentre:" {next}
$0~"^30 CH - 1015 Lausanne" {next}
$0~"^30 Offres de logement" {next}

$0~"^30 " {sub("30", "", $0); loc = loc " " $0 }
END {}
' fields.html > data.html

echo "rearranged into data"


php -r 'while(($line=fgets(STDIN)) !== FALSE) echo html_entity_decode($line, ENT_QUOTES|ENT_HTML5);' < data.html > data.txt
#perl -MHTML::Entities -alne 'print decode_entities($_)' data.html > data.txt


awk '
BEGIN {FS = "\t"}
{gsub(" ", "+", $4); print $4}
' data.txt > addresses.txt

rm lookups.txt
while read line
do
    curl  "https://maps.googleapis.com/maps/api/distancematrix/json?origins=${line}&destinations=46.522035,6.565942&mode=transit&arrival_time=1441090800&key=AIzaSyCdyOjHwORvCZQObAKnvthOQaW1FG6YZjg" >> lookups.txt
done < addresses.txt


awk '
BEGIN {i = -1}
$0~"duration" {i = 2;next}
{i--}
{if (i==0) {print $3}}
$0~"NOT_FOUND" {print ""}
' lookups.txt >> dists.txt

paste data.txt dists.txt | column >> final.txt






#curl "https://maps.googleapis.com/maps/api/distancematrix/json?origins=Sallaz-Chailly+1012+Lausanne&destinations=46.522035,6.565942&mode=transit&arrival_time=1441090800&key=AIzaSyCdyOjHwORvCZQObAKnvthOQaW1FG6YZjg"

#curl "https://maps.googleapis.com/maps/api/distancematrix/json?origins=+++Chemin+de+la+Lisière+3++1018+Lausanne+;&destinations=46.522035,6.565942&mode=transit&arrival_time=1441090800&key=AIzaSyCdyOjHwORvCZQObAKnvthOQaW1FG6YZjg"
