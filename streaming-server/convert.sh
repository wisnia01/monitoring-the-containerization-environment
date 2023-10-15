#!/bin/bash

INPUT_FILE=""

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

VIDEOS_PATH="app/videos"

rm -rf $VIDEOS_PATH

mkdir -p $VIDEOS_PATH/hls
mkdir -p $VIDEOS_PATH/mpeg-dash
mkdir -p $VIDEOS_PATH/original

ffmpeg -i $INPUT_FILE -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -f hls $VIDEOS_PATH/hls/converted-video.m3u8
ffmpeg -i $INPUT_FILE -codec copy -start_number 0 -seg_duration 10 -f dash $VIDEOS_PATH/mpeg-dash/converted-video.mpd
cp $INPUT_FILE $VIDEOS_PATH/original/original-video.mp4