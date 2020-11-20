FROM postgres:11

LABEL maintainer="PostGIS Project - https://postgis.net"

ENV POSTGIS_MAJOR 2.5

# Add timescale repository
RUN apt-get update
RUN apt install -y wget \
        apt-transport-https \
        ca-certificates \
    && sh -c "echo 'deb https://packagecloud.io/timescale/timescaledb/debian/ stretch main' > /etc/apt/sources.list.d/timescaledb.list" \
    && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | apt-key add -

COPY requirements.txt ./
RUN apt install -y python3-pip \
    && pip3 install -r requirements.txt

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-11-postgis-$POSTGIS_MAJOR \
        postgresql-plpython3-11 \
        timescaledb-postgresql-11

#RUN timescaledb-tune --quiet --yes

RUN rm -rf /var/lib/apt/lists/*

RUN sed -r -i "s/[#]*\s*(shared_preload_libraries)\s*=\s*'(.*)'/\1 = 'timescaledb,\2'/;s/,'/'/" /usr/share/postgresql/postgresql.conf.sample