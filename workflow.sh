#!/bin/bash

FILE=data/luscinia_vars.vcf.gz 
<$FILE zcat | grep -v "^#" | awk 'match($1, /^chr[1,Z]$/)' | cut -f1-6 | gzip > data/col1-6.gz
<$FILE zcat | grep -v "^#" | awk 'match($1, /^chr[1,Z]$/) {print $8}' | egrep -o 'DP=[^;]*' | sed 's/DP=//' | gzip > data/dp_val.gz
<$FILE zcat | grep -v "^#" | awk 'match($1, /^chr[1,Z]$/) {print $8}' | awk '{if($0 ~ /INDEL/) print "INDEL"; else print "SNP"}' | gzip > data/indel.gz
paste <(zcat data/col1-6.gz) <(zcat data/dp_val.gz) <(zcat data/indel.gz) | gzip > data/result.csv.gz

