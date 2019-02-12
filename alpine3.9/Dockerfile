FROM alpine:3.9

ARG MAJOR
ARG MINOR
ARG PATCH

LABEL maintainer="g0dsCookie <g0dscookie@cookieprojects.de>" \
      version="${MAJOR}.${MINOR}.${PATCH}" \
      description="Fast, free and open-source spam filtering system"

RUN set -eu \
 && cecho() { echo "\033[1;32m$1\033[0m"; } \
 && cecho "#### INSTALLING RSPAMD #####" \
 && apk add --no-cache --virtual .rspamd-deps \
       attr pcre2 openssl sqlite-libs libevent glib \
       ragel luajit fann gd icu file libnsl \
 && apk add --no-cache --virtual .rspamd-bdeps \
       gcc g++ cmake libc-dev rpcgen make tar gzip curl \
       linux-headers pcre2-dev openssl-dev sqlite-dev \
       libevent-dev glib-dev luajit-dev fann-dev gd-dev \
       icu-dev file-dev libnsl-dev \
 && MAKEOPTS="-j$(nproc)" \
 && BDIR="$(mktemp -d)" && cd "${BDIR}" \
 && curl -sSL -o "rspamd-${MAJOR}.${MINOR}.${PATCH}.tar.gz" "https://github.com/vstakhov/rspamd/archive/${MAJOR}.${MINOR}.${PATCH}.tar.gz" \
 && tar -xzf "rspamd-${MAJOR}.${MINOR}.${PATCH}.tar.gz" \
 && mkdir build && cd build \
 && cmake "../rspamd-${MAJOR}.${MINOR}.${PATCH}" \
       -DCONFDIR=/conf -DRUNDIR=/var/run/rspamd \
       -DDBDIR=/data -DLOGDIR=/logs \
       -DENABLE_LUAJIT=ON -DENABLE_FANN=ON \
       -DENABLE_GD=ON -DENABLE_PCRE2=ON \
       -DENABLE_JEMALLOC=OFF -DENABLE_TORCH=ON \
       -DENABLE_HYPERSCANN=OFF -DCMAKE_INSTALL_PREFIX="/usr" \
 && make ${MAKEOPTS} && make install && cd \
 && cecho "##### CLEANING BUILD ENVIRONMENT #####" \
 && rm -r "${BDIR}" && apk del .rspamd-bdeps \
 && cecho "##### CREATING RSPAMD USER #####" \
 && addgroup -S rspamd \
 && adduser -h /data -H -s /sbin/nologin -S -g rspamd rspamd \
 && ln -s /conf /etc/rspamd \
 && ln -s /var/lib/rspamd /data \
 && mkdir -p /conf/local.d /conf/override.d /logs \
 && chown -h rspamd:rspamd /data /logs

VOLUME [ "/conf/local.d", "/conf/override.d", "/data", "/logs" ]

EXPOSE 11332 11333 11334

ENTRYPOINT [ "rspamd", "-f", "-u", "rspamd", "-g", "rspamd" ]
