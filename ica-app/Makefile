build:
	docker build -t wjallen/ica:1.0.0 .

run:
	docker run --rm -it -v $$PWD/test:/test wjallen/ica:1.0.0 /bin/bash

push:
	docker push wjallen/ica:1.0.0

deploy:
	tapis apps deploy -W . -F app.json --ini project.ini
