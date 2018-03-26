FROM nginx
ARG PROJECT=laravel5
RUN  rm -rf /var/www/* && \
	mkdir -p /var/www/${PROJECT}
WORKDIR /var/www/${PROJECT}
COPY . /var/www/${PROJECT}
