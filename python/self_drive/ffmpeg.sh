if [ $# -ne 1 ]; then
	echo "err argument"
	exit
fi
if [ $1 == "pull" ]; then
	ffmpeg -i "rtmp://3891.liveplay.myqcloud.com/live/3891_user_3aefbfad_45a6" -c copy dump.flv

elif [ $1 == "push" ]; then

	ffmpeg -re -stream_loop -1 -i test.mp4 -c copy -f flv "rtmp://3891.livepush.myqcloud.com/live/3891_user_3aefbfad_45a6?bizid=3891&txSecret=affdd90fd95ba138c23c6b4e900c1005&txTime=5B553853"

fi

#ffmpeg -f image2 -i image%d.jpg test.mp4
#ffmpeg -i test.mp4 image%d.jpg
