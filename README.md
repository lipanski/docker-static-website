# docker-static-website

A very small Docker image (~154KB) to run any static website, based on the [BusyBox httpd](https://www.busybox.net/) static file server.

> If you're using the previous version (1.x, based on *thttpd*), I recommend upgrading since the new version (2.x) comes with a much smaller memory footprint.

For more details, check out [my article](https://lipanski.com/posts/smallest-docker-image-static-website).

## Usage

The image is hosted on [Docker Hub](https://hub.docker.com/r/lipanski/docker-static-website):

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

CMD ["/busybox", "httpd", "-f", "-v", "-p", "3000"]
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
E404:/path/e404.html # /path/e404.html is the 404 (not found) error page
```

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
