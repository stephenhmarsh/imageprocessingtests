#!/bin/bash
FILES=./originals/*
rm -rf ./output/timed1
rm -rf ./output/timed2
rm -rf ./output/timed3
rm -rf ./output/timed4
mkdir output
mkdir output/timed1
mkdir output/timed2
mkdir output/timed3
mkdir output/timed4


# TEST 1: convert 4 sizes from the original image each time
# TEST 2: create large image and convert other 3 sizes from large
# TEST 3: create large, medium&cover from large, thumb from medium
# TEST 4: repeat test 2 with greater compression settings


start_time=`date +%s`

for f in $FILES
do
  bn=$(basename $f)

  #large
  convert "./originals/$bn" -resize '1600x1600>' -quality 85 -strip "./output/timed1/large_$bn"

  #cover
  convert "./originals/$bn" -resize '210x300^' -crop '180x270+15+15' -adaptive-sharpen '0x0.6' -quality 85 -strip "./output/timed1/cover_$bn"

  #medium
  convert "./originals/$bn" -resize '250' -adaptive-sharpen '0x0.6' -quality 85 -strip "./output/timed1/medium_$bn"

  #thumb
  convert "./originals/$bn" -resize '150x150' -adaptive-sharpen '0x0.6' -quality 85 -strip "./output/timed1/thumb_$bn"

done


# convert /Users/cac6982/Desktop/originals/Moebius - 40 days dans le Désert B 2.jpeg -resize '1600x1600>' -quality 85 -strip ./output/timed/large_$f

end_time=`date +%s`
echo execution time for processing from originals was `expr $end_time - $start_time` s.



start_time2=`date +%s`

for f in $FILES
do
  bn=$(basename $f)

  #large
  convert "./originals/$bn" -resize '1600x1600>' -quality 85 -strip "./output/timed2/large_$bn"

  #cover
  convert "./output/timed2/large_$bn" -resize '210x300^' -crop '180x270+15+15' -adaptive-sharpen '0x0.6' -quality 85 -strip "./output/timed2/cover_$bn"

  #medium
  convert "./output/timed2/large_$bn" -resize '250' -adaptive-sharpen '0x0.6' -quality 85 -strip "./output/timed2/medium_$bn"

  #thumb
  convert "./output/timed2/large_$bn" -resize '150x150' -adaptive-sharpen '0x0.6' -quality 85 -strip "./output/timed2/thumb_$bn"

done


# convert /Users/cac6982/Desktop/originals/Moebius - 40 days dans le Désert B 2.jpeg -resize '1600x1600>' -quality 85 -strip ./output/timed/large_$f

end_time2=`date +%s`
echo execution time for processing from large was `expr $end_time2 - $start_time2` s.




start_time3=`date +%s`

for f in $FILES
do
  bn=$(basename $f)

  #large
  convert "./originals/$bn" -resize '1600x1600>' -quality 85 -strip "./output/timed3/large_$bn"

  #cover
  convert "./output/timed3/large_$bn" -resize '210x300^' -crop '180x270+15+15' -adaptive-sharpen '0x0.6' -quality 85 -strip "./output/timed3/cover_$bn"

  #medium
  convert "./output/timed3/large_$bn" -resize '250' -adaptive-sharpen '0x0.6' -quality 85 -strip "./output/timed3/medium_$bn"

  #thumb
  convert "./output/timed3/medium_$bn" -resize '150x150' -adaptive-sharpen '0x0.6' -quality 85 -strip "./output/timed3/thumb_$bn"

done

start_time4=`date +%s`

for f in $FILES
do
  bn=$(basename $f)

  #large
  convert "./originals/$bn" -resize '1600x1600>' -quality 80 -strip "./output/timed4/large_$bn"

  #cover
  convert "./output/timed4/large_$bn" -resize '210x300^' -crop '180x270+15+15' -adaptive-sharpen '0x0.6' -quality 75 -strip "./output/timed4/cover_$bn"

  #medium
  convert "./output/timed4/large_$bn" -resize '250' -adaptive-sharpen '0x0.6' -quality 75 -strip "./output/timed4/medium_$bn"

  #thumb
  convert "./output/timed4/large_$bn" -resize '150x150' -adaptive-sharpen '0x0.6' -quality 75 -strip "./output/timed4/thumb_$bn"

done


# convert /Users/cac6982/Desktop/originals/Moebius - 40 days dans le Désert B 2.jpeg -resize '1600x1600>' -quality 85 -strip ./output/timed/large_$f

end_time4=`date +%s`
echo execution time for processing from large with extra compression was `expr $end_time4 - $start_time4` s.




# convert /Users/cac6982/Desktop/originals/Moebius - 40 days dans le Désert B 2.jpeg -resize '1600x1600>' -quality 85 -strip ./output/timed/large_$f

end_time3=`date +%s`
echo execution time for processing from next largest was `expr $end_time3 - $start_time3` s.



# roll up & repeat all output times
echo execution time for processing from originals was `expr $end_time - $start_time` s.
echo execution time for processing from large was `expr $end_time2 - $start_time2` s.
echo execution time for processing from next largest was `expr $end_time3 - $start_time3` s.
echo execution time for processing from large with extra compression was `expr $end_time4 - $start_time4` s.