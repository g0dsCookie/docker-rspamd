FROM alpine:3.7

##### VERSIONS #####
ARG MAJOR
ARG MINOR
ARG PATCH
##### VERSIONS #####

##### BUILDOPTIONS #####
ARG MAKEOPTS=-j1
ARG CFLAGS=-O2
ARG CPPFLAGS=-O2
##### BUILDOPTIONS #####

ADD docker-entrypoint.sh /docker-entrypoint.sh

RUN set -eu \
 && apk add --no-cache --virtual .rspamd-deps \
        attr \
        pcre2 \
        libressl \
        sqlite-libs \
        libevent \
        glib \
        ragel \
        luajit \
        fann \
        gd \
        icu \
        file \
        libnsl \
 && apk add --no-cache --virtual .build-deps \
        gcc g++ cmake \
        libc-dev rpcgen \
        make tar gzip wget \
        linux-headers \
        pcre2-dev \
        libressl-dev \
        sqlite-dev \
        libevent-dev \
        glib-dev \
        luajit-dev \
        fann-dev \
        gd-dev \
        icu-dev \
        file-dev \
        libnsl-dev \
 && addgroup -S rspamd \
 && adduser -h "/data" -H -s /sbin/nologin -S -g rspamd rspamd \
 && mkdir -p "/data" \
 && chown rspamd:rspamd "/data" \
 && BDIR="$(mktemp -d)" \
 && cd "${BDIR}" \
 && wget -qO - "https://github.com/vstakhov/rspamd/archive/${MAJOR}.${MINOR}.${PATCH}.tar.gz" |\
    tar -xzf - \
 && mkdir "rspamd.build" \
 && cd "rspamd.build" \
 && cmake "../rspamd-${MAJOR}.${MINOR}.${PATCH}" \
        -DCONFDIR=/conf \
        -DRUNDIR=/var/run/rspamd \
        -DDBDIR=/data \
        -DLOGDIR=/log \
        -DENABLE_LUAJIT=ON \
        -DENABLE_FANN=ON \
        -DENABLE_GD=ON \
        -DENABLE_PCRE2=ON \
        -DENABLE_JEMALLOC=OFF \
        -DENABLE_TORCH=ON \
        -DENABLE_HYPERSCANN=OFF \
 && make ${MAKEOPTS} CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" \
 && make install \
 && cd \
 && rm -r "${BDIR}" \
 && apk del .build-deps \
 && ln -s /conf /etc/rspamd \
 && ln -s /var/lib/rspamd /data \
 && mkdir -p /conf/{local,override}.d

VOLUME [ "/conf", "/data", "/log" ]

EXPOSE 11332 11333 11334

ENTRYPOINT [ "/docker-entrypoint.sh", "rspamd", "-f", "-u", "rspamd", "-g", "rspamd" ]