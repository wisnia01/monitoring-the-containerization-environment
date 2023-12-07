#!/bin/bash

# Define input and output paths
INPUT_FILE="sinteltrailer.mp4"
OUTPUT_PATH="app/videos/hls-multi-res"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_PATH

# ffmpeg -i "$INPUT_FILE" \
#   -map 0:v:0 -map 0:a:0 -map 0:v:0 -map 0:a:0 \
#   -c:v libx264 -crf 0 -c:a aac -ar 44100 \
#   -filter:v:0 scale=w=480:h=360  -maxrate:v:0 600k -b:a:0 64k \
#   -filter:v:1 scale=w=1280:h=720 -maxrate:v:1 3000k -b:a:1 128k \
#   -var_stream_map "v:0,a:0,name:360p v:1,a:1,name:720p" \
#   -preset slow -hls_list_size 10 -threads 0 -f hls \
#   -hls_time 3 -hls_flags independent_segments \
#   -master_pl_name "hlsstream.m3u8" \
#   -y "$OUTPUT_PATH/hlsstream-%v.m3u8"

ffmpeg -i "$INPUT_FILE" -profile:v baseline -level 3.0 -s 640x360 -start_number 0 -hls_time 3 -hls_list_size 0 -f hls $OUTPUT_PATH/hls-stream-360p.m3u8
ffmpeg -i "$INPUT_FILE" -profile:v baseline -level 3.0 -s 1280x720 -start_number 0 -hls_time 3 -hls_list_size 0 -f hls $OUTPUT_PATH/hls-stream-720p.m3u8
touch $OUTPUT_PATH/hls-stream.m3u8
printf '#EXTM3U\n#EXT-X-STREAM-INF:BANDWIDTH=375000,RESOLUTION=640x360\nhls-stream-360p.m3u8\n#EXT-X-STREAM-INF:BANDWIDTH=2000000,RESOLUTION=1280x720\nhls-stream-720p.m3u8\n' > $OUTPUT_PATH/hls-stream.m3u8


