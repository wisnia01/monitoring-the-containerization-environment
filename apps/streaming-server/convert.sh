#!/bin/bash

INPUT_FILE=""
OUTPUT_PATH="app/streams"

while getopts i: flag
do
  case "${flag}" in
    i) INPUT_FILE=${OPTARG};;
  esac
done

if [ ! -f $INPUT_FILE ]; then
  echo "File not found! Please provide a .mp4 file via -i option, e.g. ./convert.sh -i my-video.mp4"
  exit 1
elif [ -z $INPUT_FILE ]; then
  echo "No input file provided! Please use -i option to specify a .mp4 file."
  exit 1
elif [[ $INPUT_FILE != *.mp4 ]]; then
  echo "Incorrect file type provided! Please provide a .mp4 file."
  exit 1
fi

rm -rf $OUTPUT_PATH
mkdir -p $OUTPUT_PATH/hls
mkdir -p $OUTPUT_PATH/mpeg-dash
mkdir -p $OUTPUT_PATH/original
mkdir -p $OUTPUT_PATH/hls-abr

start=`date +%s`
# HLS
ffmpeg -i $INPUT_FILE \
  -vcodec libx264 \
  -acodec aac \
  -start_number 0 \
  -hls_time 3 \
  -hls_list_size 0 \
  -f hls $OUTPUT_PATH/hls/hls-stream.m3u8
end=`date +%s`
echo "Elapsed time for HLS with re-encoding: $((end-start))"

start=`date +%s`
# MPEG-DASH
ffmpeg -i $INPUT_FILE \
  -codec copy \
  -start_number 0 \
  -seg_duration 3 \
  -f dash $OUTPUT_PATH/mpeg-dash/mpeg-dash-stream.mpd
end=`date +%s`
echo "Elapsed time for MPEG-DASH without re-encoding: $((end-start))"

# HLS with ABR
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

cp $INPUT_FILE $OUTPUT_PATH/original/original-video.mp4
