#!/bin/bash

if [ -z ${1+x} ]; then 
    f="3"
else
    f=$1
fi

#echo $f

(head -n 2 score.sc && tail -n +3 score.sc | sort -k2 -nr) > newscore.sc

perl renaming.pl
perl sort_score.pl
perl sum_score.pl $f
rm -rf newscore.sc
