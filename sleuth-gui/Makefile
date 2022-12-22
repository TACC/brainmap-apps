APPID ?= wallen-sleuth-gui-3.0.4


build:
	docker build -t wjallen/sleuth:3.0.4 .

run:
	xhost + 127.0.0.1
	docker run -e DISPLAY=host.docker.internal:0 wjallen/sleuth:3.0.4 java -jar /app/Sleuth.jar

inter:
	docker run --rm -it wjallen/sleuth:3.0.4 /bin/bash

push:
	docker push wjallen/sleuth:3.0.4


list:
	tapis apps search --id start wallen

deploy:
	tapis apps deploy -W . -F app.json --ini project.ini

update:
	tapis apps update -F app.json --ini project.ini ${APPID}
