#PREAMBLE

FROM julia:alpine
LABEL maintainer "David Molik <david.molik@usda.gov>"

WORKDIR /home/genomics
COPY . /home/genomics
RUN cd /home/genomics

RUN apk update \
    && apk upgrade

#MAIN

RUN bin/install.jl \
    && pwd \
    && ls \ 
    && cp bin/shh.jl /usr/local/bin \
    && cd /home/genomics \
    && rm -rf *.tgz *.tar *.zip \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

