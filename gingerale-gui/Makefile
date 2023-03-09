APPID ?= wallen-gingerale-gui-3.0.2

list:
	tapis apps search --id start wallen

deploy:
	tapis apps deploy -W . -F app.json --ini project.ini --no-build --no-push

update:
	tapis apps update -F app.json --ini project.ini ${APPID}


build:
	docker build -t wjallen/gingerale:3.0.2 .

run:
	xhost + 127.0.0.1
	docker run -e DISPLAY=host.docker.internal:0 wjallen/gingerale:3.0.2 java -jar /app/GingerALE.jar

inter:
	docker run --rm -it wjallen/gingerale:3.0.2 /bin/bash

push:
	docker push wjallen/gingerale:3.0.2
	
