nginx/1.4.6 (Ubuntu) + PHP7.0 (fpm)

# Build docker image
docker build -t movie_seat_image .

# Run docker
$ docker run --name movie_seat_instance -it movie_seat_image

# Run docker with forward ip address
$ docker run -p 10.11.252.97:8080:80 -it movie_seat_image

# Delete docker image by ID
docker rmi -f <image-id>

$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
b18889f8a58a        movie_seat_image    "/usr/bin/supervisord"   14 seconds ago      Up 13 seconds       80/tcp              movie_seat_instance

$ docker inspect --format='{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq)
/evil_allen - 172.17.0.2
/thirsty_elion -
/angry_hugle -
/infallible_shirley -
/angry_bartik -
/sad_hoover -

$ docker inspect b18889f8a58a | grep -w "IPAddress" | awk '{ print $2 }' | head -n 1 | cut -d "," -f1
"172.17.0.2"

# SSH to docker container
export TERM=xterm
$ docker exec -i -t b18889f8a58a /bin/bash


# Docker history
$ docker history movie_seat_image
$ docker tag 64350cabd1d4 movie_seat_image

# Uninstall Nginx
apt-get remove nginx nginx-common # Removes all but config files.

apt-get purge nginx nginx-common # Removes everything.

sudo apt-get autoremove # After using any of the above commands, use this in order to remove dependencies used by nginx which are no longer required.

# Update and create new image repo with tags
$ docker commit -m "add folder /run/php for php fpm" -a "Trung Dmm" <container id> movie_seat_image:v2

sha256:dd2c4c258bbf5e23af09ff5bbd7a9435ea52efb6eb434373f6caf6def85c7c43

# Remove docker container
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

Now, can be done in one line
docker rm -f $(docker ps -a -q)

# push a docker image to
$ docker tag movie_seat_image:latest minhtrung/movie-seat

$ docker push minhtrung/movie-seat

```
You need to tag your image correctly first with your registryhost:
docker tag [OPTIONS] IMAGE[:TAG] [REGISTRYHOST/][USERNAME/]NAME[:TAG]
docker push NAME[:TAG]
```

# debug nginx error config
## nginx -t -c /etc/nginx/nginx.conf
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful


