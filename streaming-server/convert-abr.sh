#!/bin/bash

# Define input and output paths
INPUT_FILE="sinteltrailer.mp4"
OUTPUT_PATH="app/videos"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_PATH

ffmpeg -i $INPUT_FILE \
  -c:a aac \
  -c:v libx264 \
  -profile:v high \
  -level:v 4.0 \
  -s 256x144 \
  -start_number 0 \
  -hls_time 3 \
  -hls_list_size 0 \
  -f hls $OUTPUT_PATH/hls-abr/hls-stream-144p.m3u8

ffmpeg -i $INPUT_FILE \
  -c:a aac \
  -c:v libx264 \
  -profile:v high \
  -level:v 4.0 \
  -s 1280x720 \
  -start_number 0 \
  -hls_time 3 \
  -hls_list_size 0 \
  -f hls $OUTPUT_PATH/hls-abr/hls-stream-720p.m3u8

touch $OUTPUT_PATH/hls-abr/hls-stream.m3u8
printf '#EXTM3U\n#EXT-X-STREAM-INF:BANDWIDTH=50000,RESOLUTION=256x144\nhls-stream-144p.m3u8\n#EXT-X-STREAM-INF:BANDWIDTH=2000000,RESOLUTION=1280x720\nhls-stream-720p.m3u8\n' > $OUTPUT_PATH/hls-abr/hls-stream.m3u8


