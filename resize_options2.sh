#!/bin/bash
FILES=./originals/*
rm -rf ./output/final_tests
mkdir output
mkdir output/final_tests


# TEST 1: create large image and convert other 3 sizes from large - play with optimization settings

start_time4=`date +%s`

for f in $FILES
do
  bn=$(basename $f)


  #16c - full
  convert "./originals/$bn"  -resize '1985' -quality 70 -strip "./output/final_tests/full_$bn"
  #10c - large
  convert "./originals/$bn"  -resize '1229' -quality 70 -strip "./output/final_tests/large_$bn"
  #8c - med
  convert "./output/final_tests/full_$bn"  -resize '977' -quality 70 -strip "./output/final_tests/med_$bn"
  #4c - grid
  convert "./output/final_tests/full_$bn"  -resize '473' -quality 60 -strip "./output/final_tests/grid_$bn"
  #1c - thumb
  convert "./output/final_tests/full_$bn"  -resize '95' -quality 60 -strip "./output/final_tests/thumb_$bn"
  #12c - index
  convert "./originals/$bn"  -resize '1481' -quality 70 -strip "./output/final_tests/index_$bn"
  #12c - index_cropped
  convert "./originals/$bn"  -resize '1481x494^' -gravity center -extent '1481x494' -quality 70 -strip "./output/final_tests/index_cropped_$bn"

done


# convert /Users/cac6982/Desktop/originals/Moebius - 40 days dans le Désert B 2.jpeg -resize '1600x1600>' -quality 85 -strip ./resized/large_$f

end_time4=`date +%s`
#echo execution time for processing from large with extra compression was `expr $end_time4 - $start_time4` s.


# roll up & repeat all output times
echo execution time for processing resize options was `expr $end_time4 - $start_time4` s.