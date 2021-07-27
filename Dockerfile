#PREAMBLE

FROM julia:alpine
LABEL maintainer "David Molik <david.molik@usda.gov>"

WORKDIR /home/genomics
COPY . /home/genomics
RUN cd /home/genomics

RUN apk update \
    && apk upgrade

#MAIN

COPY bin/shh.jl /usr/local/bin
RUN bin/install.jl

