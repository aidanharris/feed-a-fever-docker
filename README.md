# feed-a-fever-docker
Dockerised Feed-A-Fever (http://www.feedafever.com/)

## Building:

```
git clone https://github.com/aidanharris/feed-a-fever-docker.git fever
cd fever
sudo docker build --build-arg FEVER_SHA256SUM=6a2ed36cf1566ab42d837d0d34fec1c724015450b986e889f5474984f38912b1 -t aidanharris-feed-a-fever .
```

## Usage:

### MySQL Container

`docker run -d --name=fever-data -e MYSQL_ROOT_PASSWORD="password" -v /srv/fever-data:/var/lib/mysql mysql`

### Fever

`docker run -d --name=fever -p 8080:80 --link fever-data:mysql aidanharris-feed-a-fever`

Point your browser to http://localhost:8080 and ignore any warnings / errors that may temporarily appear.
