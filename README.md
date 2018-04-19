# dovecot image

This image provides an *unofficial* dockerized rspamd image.

## Table of Contents

1. [Supported tags and versions](#supported-tags-and-versions)
2. [Quick reference](#quick-reference)
3. [How to use this image](#how-to-use-this-image)
    1. [Run the container](#run-the-container)
    2. [Use custom container](#use-custom-container)
    3. [Use bind mounts](#use-bind-mounts)
    4. [Available volumes](#available-volumes)

## Supported tags and versions

* [`1.6.6`, `1.6` (*1.6/Dockerfile*)](https://github.com/g0dsCookie/docker-rspamd/blob/master/Dockerfile)
* [`1.7.3`, `1.7`, `1`, `latest` (*1.7/Dockerfile*)](https://github.com/g0dsCookie/docker-rspamd/blob/master/Dockerfile)

## Quick reference

* **Where to file issues**:

    [https://github.com/g0dsCookie/docker-rspamd/issues](https://github.com/g0dsCookie/docker-rspamd/issues)

* **Maintained by**:

    [g0dsCookie](https://github.com/g0dsCookie)

## How to use this image

### Run the container

This container uses rspamd's default configuration.

You are highly advised to not mount your configuration directly to **/conf**.
Instead use rspamd's overrides and mount your configuration in **/conf/local.d**.

### Use custom container

```Dockerfile
FROM g0dscookie/rspamd
COPY conf.d /config/local.d
```

Now build your container with `$ docker build -t my-rspamd .`.

### Use bind mounts

`$ docker run -d --name my-rspamd -v /path/to/config:/conf/local.d:ro -v /path/to/data:/data g0dscookie/rspamd`

Note that **/path/to/config** is a directory.

### Available volumes

* /data
  * Here you can store your mails
* /conf
  * rspamd configuration files.

## Update instructions

1. Add new rspamd version to `build.py`
2. `make VERSION="<VERSION>"`
    1. Omit `VERSION=` or set `<VERSION>` to **latest** if you are building a latest version.
3. `make push`
4. Commit your changes and push them
