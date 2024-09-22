FROM alpine:3.20

RUN apk add --no-cache \
    bash \
    coreutils \
    crane \
    gawk \
    yq
