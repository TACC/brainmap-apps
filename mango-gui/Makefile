APPID ?= wallen-mango-4.1


build:
	docker build -t wjallen/mango:4.1 .

run:
	xhost + 127.0.0.1
	docker run -e DISPLAY=host.docker.internal:0 wjallen/mango:4.1 java -jar /Mango/Mango.jar

inter:
	docker run --rm -it wjallen/mango:4.1 /bin/bash

push:
	docker push wjallen/mango:4.1


list:
	tapis apps search --id start wallen

deploy:
	tapis apps deploy -W . -F app.json --ini project.ini

update:
	tapis apps update -F app.json --ini project.ini ${APPID}
