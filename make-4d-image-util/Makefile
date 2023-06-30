APPID ?= wallen-make-4d-image-1.0.0

list:
	tapis apps search --id start wallen

deploy:
	tapis apps deploy -W . -F app.json --ini project.ini --no-build --no-push

update:
	tapis apps update -F app.json --ini project.ini ${APPID}


build:
	docker build -t wjallen/make-4d-image:1.0.0 .

run:
	docker run --rm -it -v $$PWD/test:/test wjallen/make-4d-image:1.0.0 /bin/bash

push:
	docker push wjallen/make-4d-image:1.0.0
