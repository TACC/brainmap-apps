build:
	docker build -t wallen/gingerale:3.0.2 .

run:
	xhost + 127.0.0.1
	docker run -e DISPLAY=host.docker.internal:0 wallen/gingerale:3.0.2 java -jar /app/GingerALE.jar

inter:
	docker run --rm -it wallen/gingerale:3.0.2 /bin/bash
