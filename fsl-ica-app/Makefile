APPID ?= wallen-fsl-ica-6.0.5

list:
	tapis apps search --id start wallen

deploy:
	tapis apps deploy -W . -F app.json --ini project.ini --no-build --no-push

update:
	tapis apps update -F app.json --ini project.ini ${APPID}


build:
	docker build -t wjallen/fsl:6.0.5 .

run:
	docker run --rm -it -v wjallen/fsl:6.0.5 /bin/bash

push:
	docker push wjallen/fsl:6.0.5




disable:
	tapis apps disable ${APPID}

enable: 
	tapis apps enable ${APPID}
