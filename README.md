# About the project
The goal of this project is to show different conceptions regarding:
- monitoring Kubernetes applications,
- streaming (different protocols etc.),
- horizontal scaling on Kubernetes, especially of streaming applications
# Setup
In order to run this project follow these steps:
1. Download and install [ffmpeg](https://ffmpeg.org).
2. Prepare or download some .mp4 file. For example here you can download full BigBuckBunny 10 minutes movie from here: http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4
3. Place the .mp4 file in the *streaming-server/* directory
4. In the *streaming-server/* directory run: ```./convert.sh -i MY_MOVIE_FILE.mp4```
5. If you're on windows machine you can either configure WSL or make some (faster) workaround by downloading [GIT](https://git-scm.com/downloads). After downloading it you can either run the script from GIT Bash same as above or add a path to sh.exe file (for example: *C:\Program Files\Git\bin*) to PATH variable and run it from powershell like ```sh .\convert.sh -i MY_MOVIE_FILE.mp4```
6. After successfuly converting .mp4 file you can run the k8s application by executing: ```./init-k8s.sh``` in the *k8s/* directory. You can then access the application by visiting *http://localhost:30000*.
7. You can turn the application down by running: ```./clean-k8s.sh``` also in *k8s/* directory.
7. Optionally, if you'd like to run simple streaming-server Docker container without any Kubernetes you can run: ```./init-pure-docker.sh``` in the *streaming-server/* directory and visit the application on *http://localhost:8080*.