APPID ?= wallen-gingerale-vfwe-3.0.2

list:
	tapis apps search --id start wallen

deploy:
	tapis apps deploy -W . -F app.json --ini project.ini --no-build --no-push

update:
	tapis apps update -F app.json --ini project.ini ${APPID}



build:
	docker build -t wjallen/gingerale:3.0.2 .

run:
	docker run --rm -it -v wjallen/gingerale:3.0.2 /bin/bash

push:
	docker push wjallen/gingerale:3.0.2
