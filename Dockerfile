#PREAMBLE
FROM julia:alpine
LABEL maintainer "David Molik <david.molik@usda.gov>"

WORKDIR /home/genomics/
RUN cd /home/genomics/

RUN apk update \
    && apk upgrade

#MAIN

RUN julia -e "using Pkg; Pkg.add(url=\"https://github.com/molikd/Shhquis.jl\")"
    #&& bin/install.jl \
    #&& cp bin/shh.jl /usr/local/bin \
    && rm -rf *.tgz *.tar *.zip \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*
