FROM debian:11

ARG MAJOR
ARG MINOR

LABEL maintainer="g0dsCookie <g0dscookie@cookieprojects.de>" \
      version="${MAJOR}.${MINOR}" \
      description="Fast, free and open-source spam filtering system"

RUN set -eu \
 && cecho() { echo "\033[1;32m$1\033[0m"; } \
 && cecho "### PREPARE ENVIRONMENT ###" \
 && TMP="$(mktemp -d)" && PV="${MAJOR}.${MINOR}" && S="${TMP}/rspamd-${PV}" \
 && useradd -d /var/lib/rspamd -M -r rspamd \
 && mkdir /var/lib/rspamd /run/rspamd \
 && chown rspamd:rspamd /var/lib/rspamd /run/rspamd \
 && chmod 0700 /var/lib/rspamd /run/rspamd \
 && cecho "### INSTALLING DEPENDENCIES ###" \
 && apt-get update -qqy \
 && apt-get install -qqy \
      build-essential cmake ragel curl gnupg \
      libssl-dev libpcre2-dev libsqlite3-dev libevent-dev \
      libc-dev libluajit-5.1-dev libfann-dev libgd-dev \
      libicu-dev libmagic-dev libsodium-dev libjemalloc-dev \
      libhyperscan-dev libglib2.0-dev \
 && apt-get install -qqy \
      openssl libfann2 libluajit-5.1 libpcre2-8-0 libsqlite3-0 \
      libicu67 libsodium23 libhyperscan5 libglib2.0-0 libjemalloc2 \
      libevent-2.1-7 libmagic1 \
 && cecho "### DOWNLOADING RSPAMD ###" \
 && cd "${TMP}" \
 && curl -sSL --output "rspamd-${PV}.tar.gz" "https://github.com/rspamd/rspamd/archive/refs/tags/${PV}.tar.gz" \
 && tar -xf "rspamd-${PV}.tar.gz" \
 && mkdir build && cd build \
 && cmake "../rspamd-${PV}" \
      -DCONFDIR=/etc/rspamd -DRUNDIR=/run/rspamd \
      -DDBDIR=/var/lib/rspamd -DLOGDIR=/var/log/rspamd \
      -DENABLE_LUAJIT=ON -DENABLE_FANN=ON \
      -DENABLE_GD=ON -DENABLE_PCRE2=ON \
      -DENABLE_JEMALLOC=ON -DENABLE_TORCH=ON \
      -DENABLE_HYPERSCAN=ON -DCMAKE_INSTALL_PREFIX="/usr" \
 && make -j$(nproc) \
 && make install \
 && mkdir /etc/rspamd/local.d /etc/rspamd/override.d \
 && cecho "### CLEANUP ###" \
 && cd && rm -rf "${TMP}" \
 && apt-get remove -qqy \
      build-essential cmake ragel curl gnupg \
      libssl-dev libpcre2-dev libsqlite3-dev libevent-dev \
      libc-dev libluajit-5.1-dev libfann-dev libgd-dev \
      libicu-dev libmagic-dev libsodium-dev libjemalloc-dev \
      libhyperscan-dev libglib2.0-dev \
 && apt-get autoremove -qqy \
 && apt-get clean -qqy

COPY --chown=root:root defaults/ /etc/rspamd/local.d

VOLUME [ "/etc/rspamd/local.d", "/etc/rspamd/override.d", "/var/lib/rspamd", "/var/logs/rspamd" ]
EXPOSE 11332 11333 11334
USER rspamd
WORKDIR /var/lib/rspamd
ENTRYPOINT [ "rspamd", "-f" ]
