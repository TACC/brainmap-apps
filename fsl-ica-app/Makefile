APPID ?= wallen-fsl-ica-6.0.5

list:
	tapis apps search --id start wallen


# add --no-build --no-pull --no-push to deploy because this container is huge

deploy:
	tapis apps deploy -W . -F app.json --ini project.ini

update:
	tapis apps update -F app.json --ini project.ini ${APPID}
