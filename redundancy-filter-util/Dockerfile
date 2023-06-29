FROM eclipse-temurin:17.0.7_7-jdk

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libxt6
    
COPY src/make_per_experiment_TXTfiles_for_meta_ICA.m /app/make_per_experiment_TXTfiles_for_meta_ICA.m
COPY src/README.txt /app/README.txt

RUN chmod +rx /app/*.m
