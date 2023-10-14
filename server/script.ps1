docker run -d -p 1935:1935 -p 8080:8080 --name server server-image # -v custom_players:/usr/local/nginx/html/players -v videos:/videos --name server alqutami/rtmp-hls
# ffmpeg -i filename.mp4 -codec: copy -start_number 0 -hls_time 10 -hls_list_size 0 -f hls filename.m3u8
#  ffmpeg -i file.mp4 -vcodec copy -acodec copy output.mpd
