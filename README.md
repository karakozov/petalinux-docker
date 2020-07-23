# petalinux-docker

Copy petalinux-v2018.x-final-installer.run file to this folder. Then run

`docker build --build-arg PETA_VERSION=2018.x --build-arg PETA_RUN_FILE=petalinux-v2018.x-final-installer.run -t petalinux:2018.x .`

After installation, launch petalinux with:

`docker run -ti --rm -e DISPLAY=$DISPLAY --net="host" -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/home/vivado/.Xauthority -v $HOME/xproject.git:/home/vivado/xproject  petalinux:2018.3 /bin/bash`
