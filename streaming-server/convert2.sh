#!/bin/bash

# Define input and output paths
INPUT_FILE="sinteltrailer.mp4"
OUTPUT_PATH="output"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_PATH

ffmpeg -i "$INPUT_FILE" \
  -map 0:v:0 -map 0:a:0 -map 0:v:0 -map 0:a:0 -map 0:v:0 -map 0:a:0 \
  -c:v libx264 -crf 22 -c:a aac -ar 44100 \
  -filter:v:0 scale=w=480:h=360  -maxrate:v:0 600k -b:a:0 500k \
  -filter:v:1 scale=w=640:h=480  -maxrate:v:1 1500k -b:a:1 1000k \
  -filter:v:2 scale=w=1280:h=720 -maxrate:v:2 3000k -b:a:2 2000k \
  -var_stream_map "v:0,a:0,name:360p v:1,a:1,name:480p v:2,a:2,name:720p" \
  -preset fast -hls_list_size 10 -threads 0 -f hls \
  -hls_time 3 -hls_flags independent_segments \
  -master_pl_name "test.m3u8" \
  -y "$OUTPUT_PATH/test-%v.m3u8"