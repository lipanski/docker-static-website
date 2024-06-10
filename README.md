# docker-static-website

[![docker:lipanski/docker-static-website](https://img.shields.io/docker/v/lipanski/docker-static-website?logo=docker&label=lipanski%2Fdocker-static-website)](https://hub.docker.com/r/lipanski/docker-static-website/tags)

A very small Docker image (~80KB) to run any static website, based on the [BusyBox httpd](https://www.busybox.net/) static file server.

For more details, check out [my article](https://lipanski.com/posts/smallest-docker-image-static-website).

Check the [Releases](https://github.com/lipanski/docker-static-website/releases) page for new versions and breaking changes.

## Usage

The image is hosted on [Docker Hub](https://hub.docker.com/r/lipanski/docker-static-website/tags) and comes with **linux/amd64**, **linux/arm64** and **linux/arm/v7** builds:

```dockerfile
FROM lipanski/docker-static-website:latest

# Copy your static files
COPY . .
```

Build the image:

```sh
docker build -t my-static-website .
```

Run the image:

```sh
docker run -it --rm -p 3000:3000 my-static-website
```

Browse to `http://localhost:3000`.

If you need to configure the server in a different way, you can override the `CMD` line:

```dockerfile
FROM lipanski/docker-static-website:latest

# Copy your static files
COPY . .

CMD ["/busybox-httpd", "-f", "-v", "-p", "3000", "-c", "httpd.conf"]
```

**NOTE:** Sending a `TERM` signal to your TTY running the container won't get propagated due to how busybox is built. Instead you can call `docker stop` (or `docker kill` if can't wait 15 seconds). Alternatively you can run the container with `docker run -it --rm --init` which will propagate signals to the process correctly.

## FAQ

### How can I serve gzipped files?

For every file that should be served gzipped, add a matching `[FILENAME].gz` to your image.

### How can I use httpd as a reverse proxy?

Add a `httpd.conf` file and use the `P` directive:

```
P:/some/old/path:[http://]hostname[:port]/some/new/path
```

### How can I overwrite the default error pages?

Add a `httpd.conf` file and use the `E404` directive:

```
E404:e404.html
```

...where `e404.html` is your custom 404 page.

Note that the error page directive is only processed for your main `httpd.conf` file. It will raise an error if you use it in `httpd.conf` files added to subdirectories.

### How can I implement allow/deny rules?

Add a `httpd.conf` file and use the `A` and `D` directives:

```
A:172.20.         # Allow address from 172.20.0.0/16
A:10.0.0.0/25     # Allow any address from 10.0.0.0-10.0.0.127
A:127.0.0.1       # Allow local loopback connections
D:*               # Deny from other IP connections
```

You can also allow all requests with some exceptions:

```
D:1.2.3.4
D:5.6.7.8
A:* # This line is optional
```

### How can I use basic auth for some of my paths?

Add a `httpd.conf` file, listing the paths that should be protected and the corresponding credentials:

```
/admin:my-user:my-password # Require user my-user with password my-password whenever calling /admin
```

### Where can I find the documentation for BusyBox httpd?

Read the [source code comments](https://git.busybox.net/busybox/tree/networking/httpd.c).

### How can I run this in Docker Compose?

Create a `docker-compose.yml` file:

```
---
version: "3.9"
services:
  webserver:
    image: lipanski/docker-static-website:latest
    restart: always
    ports:
      - "3000:3000"
    volumes:
      - /some/local/path:/home/static
      - ./httpd.conf:/home/static/httpd.conf:ro
```

Make sure to change `/some/local/path` to the path to your static files. Include an empty or valid `httpd.conf` file.

If you use Podman, consider appending the `Z` option to volumes for SELinux labels to apply.

## Development

Clone the [busybox repo](https://git.busybox.net/busybox/tree) and create a blank config:

```
make allnoconfig
```

Copy the resulting `.config` to this project, diff it against the old one and re-enable everything that seems reasonable (mostly the `HTTPD` features).

Uncomment the `COPY . .` line in the `Dockerfile`, add a dummy `index.html` and build a test image:

```
docker build -t docker-static-website-test .
```

Then run it:

```
docker run -it --rm --init -p 3000:3000 docker-static-website-test
```

Browse to `http://localhost:3000` and check that the contents of the `index.html` file were rendered correctly.

## Release

Images are build automatically by Github Actions whenever a new tag is pushed:

```
git tag 1.2.3
git push --tags
```

### Manual process

Build the image:

```
docker build -t lipanski/docker-static-website:1.2.3 -t lipanski/docker-static-website:latest .
```

Push the image to Docker Hub:

```
docker push lipanski/docker-static-website:1.2.3
docker push lipanski/docker-static-website:latest
```
