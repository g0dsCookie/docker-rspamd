FROM alpine:3.11

ARG MAJOR
ARG MINOR

LABEL maintainer="g0dsCookie <g0dscookie@cookieprojects.de>" \
      version="${MAJOR}.${MINOR}" \
      description="Fast, free and open-source spam filtering system"

RUN set -eu \
 && apk add --no-cache --virtual .rspamd-deps \
 	attr pcre2 openssl sqlite-libs libevent glib \
	ragel luajit fann gd icu file libnsl libsodium \
 && addgroup -S rspamd \
 && adduser -h /var/lib/rspamd -H -s /sbin/nologin -S -g rspamd rspamd

RUN set -eu \
 && apk add --no-cache --virtual .rspamd-bdeps \
       gcc g++ cmake libc-dev rpcgen make tar gzip curl \
       linux-headers pcre2-dev openssl-dev sqlite-dev \
       libevent-dev glib-dev luajit-dev fann-dev gd-dev \
       icu-dev file-dev libnsl-dev libsodium-dev \
 && MAKEOPTS="-j$(nproc)" \
 && BDIR="$(mktemp -d)" && cd "${BDIR}" \
 && curl -sSL -o "rspamd-${MAJOR}.${MINOR}.tar.gz" "https://github.com/vstakhov/rspamd/archive/${MAJOR}.${MINOR}.tar.gz" \
 && tar -xzf "rspamd-${MAJOR}.${MINOR}.tar.gz" \
 && mkdir build && cd build \
 && cmake "../rspamd-${MAJOR}.${MINOR}" \
       -DCONFDIR=/etc/rspamd -DRUNDIR=/var/run/rspamd \
       -DDBDIR=/var/lib/rspamd -DLOGDIR=/var/logs/rspamd \
       -DENABLE_LUAJIT=ON -DENABLE_FANN=ON \
       -DENABLE_GD=ON -DENABLE_PCRE2=ON \
       -DENABLE_JEMALLOC=OFF -DENABLE_TORCH=ON \
       -DENABLE_HYPERSCANN=OFF -DCMAKE_INSTALL_PREFIX="/usr" \
 && make -j$(nproc) ${MAKEOPTS} && make install && cd \
 && rm -r "${BDIR}" \
 && apk del .rspamd-bdeps \
 && mkdir -p /etc/rspamd/local.d /etc/rspamd/override.d /var/lib/rspamd /var/logs/rspamd \
 && chown -h rspamd:rspamd /var/lib/rspamd /var/logs/rspamd

VOLUME [ "/etc/rspamd/local.d", "/etc/rspamd/override.d", "/var/lib/rspamd", "/var/logs/rspamd" ]

EXPOSE 11332 11333 11334

ENTRYPOINT [ "rspamd", "-f", "-u", "rspamd", "-g", "rspamd" ]
