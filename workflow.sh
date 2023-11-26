#!/bin/bash

INPUT=data/luscinia_vars.vcf.gz

first_6() {
    # obtaining first 6 columns
#    echo "$1"
    cut -f1-6 |
    gzip > "$1"
}

get_dp() {
    # obtaining dp stuff
    echo "$1"
    cut -f8 |
    egrep -o 'DP=[^;]*' |
    sed 's/DP=//' |
    gzip > "$1"
}

get_indel() {
    # indel stuff
#    echo "$1"
    awk '{if($8 ~ /INDEL/) print "INDEL"; else print "SNP"}' |
    gzip > "$1"
}

#filtering the data
<$INPUT zcat |
  grep -v "^#" |
  awk 'match($1, /^chr[1,Z]$/)' |
  tee \
    >(first_6 data/col1-6.tsv.gz) \
    >(get_dp data/dp_val.tsv.gz) \
    >(get_indel data/indel.tsv.gz) \
  > /dev/null

# concatenating them thogether
paste <(zcat data/col1-6.tsv.gz) <(zcat data/dp_val.tsv.gz) <(zcat data/indel.tsv.gz) | \
  gzip \
> data/chr1_chrZ_plotting.tsv.gz

# checking if everything is ok
sleep 1 # for some reason data is not flushed immediately
wc -l data/*
find data/* -type f -print0 | xargs -0 -I{} sh -c "zcat {} | wc -l"
