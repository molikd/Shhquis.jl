#PREAMBLE
FROM julia:1.5.0-alpine
LABEL maintainer "David Molik <david.molik@usda.gov>"

WORKDIR /home/genomics/
RUN cd /home/genomics/

RUN apk update \
    && apk upgrade \
    && apk add bash

#MAIN

ENV USER root
ENV USER_HOME_DIR /${USER}
ENV JULIA_DEPOT_PATH ${USER_HOME_DIR}/.julia

RUN julia -e "using Pkg; Pkg.add(url=\"https://github.com/molikd/Shhquis.jl\")" \
    && wget https://raw.githubusercontent.com/molikd/Shhquis.jl/main/bin/shh.jl -O /usr/local/bin/shh.jl \
    && chmod a+x /usr/local/bin/shh.jl \
    && wget https://raw.githubusercontent.com/molikd/Shhquis.jl/main/bin/install.jl -O /usr/local/bin/install.jl \
    && chmod a+x /usr/local/bin/install.jl \
    && /usr/local/bin/install.jl \ 
    && rm /usr/local/bin/install.jl \
    && rm -rf *.tgz *.tar *.zip \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*
