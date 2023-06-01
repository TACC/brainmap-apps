APPID ?= wallen-graph-theory-1.0.0

list:
	tapis apps search --id start wallen

deploy:
	tapis apps deploy -W . -F app.json --ini project.ini --no-build --no-push

update:
	tapis apps update -F app.json --ini project.ini ${APPID}


build:
	docker build -t wjallen/graph-theory:1.0.0 .

run:
	docker run --rm -it -v wjallen/graph-theory:1.0.0 /bin/bash

push:
	docker push wjallen/graph-theory:1.0.0
