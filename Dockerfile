#PREAMBLE

FROM julia:alpine
LABEL maintainer "David Molik <david.molik@usda.gov>"

RUN apk update \
    && apk upgrade

#MAIN

RUN bin/install.jl \
    && cp bin/shh.jl /usr/local/bin \
    && rm -rf *.tgz *.tar *.zip \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

