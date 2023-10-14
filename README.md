# Setup
In order to provide appropriate files first download some mp4 file like BigBuckBunny.mp4
Install ffmpeg
Run these commands:
ffmpeg -i <input_file_name>.mp4 -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -f hls <output_file_name>.m3u8
ffmpeg -i <input_file_name>.mp4 -vcodec copy -acodec copy <output_file_name>.mpd