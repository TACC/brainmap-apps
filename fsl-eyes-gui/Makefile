APPID ?= wallen-fsl-eyes-1.3.0


build:
	docker build -t wjallen/fsleyes:1.3.0 .

run:
	xhost + 127.0.0.1
	docker run -e DISPLAY=host.docker.internal:0 wjallen/fsleyes:1.3.0 fsleyes

inter:
	docker run --rm -it wjallen/fsleyes:1.3.0 /bin/bash

push:
	docker push wjallen/fsleyes:1.3.0


list:
	tapis apps search --id start wallen

deploy:
	tapis apps deploy -W . -F app.json --ini project.ini

update:
	tapis apps update -F app.json --ini project.ini ${APPID}
