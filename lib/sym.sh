#!/bin/bash
init=0x2600

for((i=0x2600 ; i<=0x26FF ; i++))
do
 sym=`echo "obase=16; $i" | bc`
 sym="\u$sym"
 echo -n "${sym}: "
 echo -e $sym
done

