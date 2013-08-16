#!/bin/bash
FILES=./originals/*
rm -rf ./output/single_compression
mkdir output
mkdir output/single_compression


# TEST 1: create large image and convert other 3 sizes from large - play with optimization settings

start_time4=`date +%s`

for f in $FILES
do
  bn=$(basename $f)

  #large
  convert "./originals/$bn" -resize '1600x1600>' -quality 80 -strip "./output/single_compression/large_$bn"

  #cover
  convert "./output/single_compression/large_$bn" -resize '210x300^' -crop '180x270+15+15' -adaptive-sharpen '0x0.6' -quality 75 -strip "./output/single_compression/cover_$bn"

  #medium
  convert "./output/single_compression/large_$bn" -resize '250' -adaptive-sharpen '0x0.6' -quality 75 -strip "./output/single_compression/medium_$bn"

  #thumb
  convert "./output/single_compression/large_$bn" -resize '150x150' -adaptive-sharpen '0x0.6' -quality 75 -strip "./output/single_compression/thumb_$bn"

done


# convert /Users/cac6982/Desktop/originals/Moebius - 40 days dans le Désert B 2.jpeg -resize '1600x1600>' -quality 85 -strip ./resized/large_$f

end_time4=`date +%s`
echo execution time for processing from large with extra compression was `expr $end_time4 - $start_time4` s.


# roll up & repeat all output times
echo execution time for processing from large with extra compression was `expr $end_time4 - $start_time4` s.