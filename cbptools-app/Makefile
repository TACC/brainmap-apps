APPID ?= wallen-cbptools-1.1.6

list:
	tapis apps search --id start wallen

deploy:
	tapis apps deploy -W . -F app.json --ini project.ini --no-build --no-push

update:
	tapis apps update -F app.json --ini project.ini ${APPID}


build:
	docker build -t wjallen/cbptools:1.1.6 .

run:
	docker run --rm -it wjallen/cbptools:1.1.6 /bin/bash

push:
	docker push wjallen/cbptools:1.1.6
