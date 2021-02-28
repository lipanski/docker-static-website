# This Dockerfile produces a larger image (~8MB) but doesn't require
# the multi-stage approach and is easier to read.

FROM alpine:3.13.2

# Install thttpd
RUN apk add thttpd

# Create a non-root user to own the files and run our server
RUN adduser -D static
USER static
WORKDIR /home/static

# Copy the static website
# Use the .dockerignore file to control what ends up inside the image!
COPY . .

# Run thttpd
CMD ["thttpd", "-D", "-h", "0.0.0.0", "-p", "3000", "-d", "/home/static", "-u", "static", "-l", "-", "-M", "60"]
