FROM alpine:3.13.2 AS builder
ARG THTTPD_VERSION=2.29
RUN apk add gcc musl-dev make
RUN wget http://www.acme.com/software/thttpd/thttpd-${THTTPD_VERSION}.tar.gz \
  && tar xzf thttpd-${THTTPD_VERSION}.tar.gz \
  && mv /thttpd-${THTTPD_VERSION} /thttpd
WORKDIR /thttpd
RUN ./configure && make CCOPT='-O2 -s -static' thttpd
RUN adduser -D static

FROM scratch
EXPOSE 3000
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /thttpd/thttpd /
USER static
WORKDIR /home/static
COPY . .
CMD ["/thttpd", "-D", "-h", "0.0.0.0", "-p", "3000", "-d", "/home/static", "-u", "static", "-l", "-", "-M", "60"]
