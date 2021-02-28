# docker-static-website

A very small Docker image (~200KB) to run any static website, based on the [thttpd](https://www.acme.com/software/thttpd/) static file server.

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

Alternatively, you can also copy and use the `Dockerfile` inside this Git repository.
