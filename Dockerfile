FROM julia:1.12-bookworm

LABEL org.opencontainers.image.title="Shhquis.jl" \
      org.opencontainers.image.description="Scaffold and orient genome assemblies from hicstuff contact data" \
      org.opencontainers.image.source="https://github.com/molikd/Shhquis.jl" \
      org.opencontainers.image.licenses="LicenseRef-US-Government-Work"

RUN useradd --create-home --shell /bin/bash shhquis

WORKDIR /opt/shhquis
COPY Project.toml ./
COPY src ./src
COPY bin/shh.jl /usr/local/bin/shhquis

# Resolve the package from the checked-out source so tagged images always
# contain the exact code associated with their Git tag.
RUN chmod 0755 /usr/local/bin/shhquis \
    && julia --project=/opt/shhquis -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'

ENV JULIA_PROJECT=/opt/shhquis \
    JULIA_NUM_THREADS=auto

USER shhquis
WORKDIR /data

ENTRYPOINT ["shhquis"]
CMD ["--help"]
