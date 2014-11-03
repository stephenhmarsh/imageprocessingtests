#!/bin/bash
FILES=./originals/*
rm -rf ./output/resize_options
mkdir output
mkdir output/resize_options


# TEST 1: create large image and convert other 3 sizes from large - play with optimization settings

start_time4=`date +%s`

for f in $FILES
do
  bn=$(basename $f)

  #16c
  convert "./originals/$bn" -resize '2520' -quality 75 -strip "./output/resize_options/16c_$bn"

  #10c
  convert "./originals/$bn"  -resize '1560' -quality 75 -strip "./output/resize_options/10c_$bn"

  #8c
  convert "./originals/$bn"  -resize '1240' -quality 75 -strip "./output/resize_options/8c_$bn"

  #6c
  convert "./originals/$bn"  -resize '920' -quality 75 -strip "./output/resize_options/6c_$bn"

  #4c
  convert "./originals/$bn"  -resize '600' -adaptive-sharpen '0x0.6' -quality 75 -strip "./output/resize_options/4c_$bn"

  #3c
  convert "./originals/$bn"  -resize '440' -adaptive-sharpen '0x0.6' -quality 75 -strip "./output/resize_options/3c_$bn"

  #1c
  convert "./originals/$bn"  -resize '120' -adaptive-sharpen '0x0.6' -quality 75 -strip "./output/resize_options/1c_$bn"

done


# convert /Users/cac6982/Desktop/originals/Moebius - 40 days dans le Désert B 2.jpeg -resize '1600x1600>' -quality 85 -strip ./resized/large_$f

end_time4=`date +%s`
#echo execution time for processing from large with extra compression was `expr $end_time4 - $start_time4` s.


# roll up & repeat all output times
echo execution time for processing resize options was `expr $end_time4 - $start_time4` s.