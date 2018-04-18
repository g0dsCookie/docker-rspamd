#!/usr/bin/env sh

setfattr -n user.pax.flags -v em $(which rspamd) $(which rspamadm)
exec $@