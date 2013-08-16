imageprocessingtests
======================

test scripts and images for processing and reprocessing tests

scripts use imagemagick @convert@ commands to test image processing.

image files in "originals" represent a variety of file types (content team source JPGs, JPGs from the web, GIFs that have caused problems in the past, etc). If we find an image that causes a problem in the system we should add it to the originals bucket.

scripts will process images into different "output" folders, allowing review of compression or other output


Current Scripts
===============

# processing_time_test.sh - processes the images using a variety of different workflow paths (all from original, from large, etc) to test speed
# single_compression_test.sh - does one loop through the source files in order to test optimization/compression settings