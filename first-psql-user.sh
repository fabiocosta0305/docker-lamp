#!/bin/sh

su postgres -c '/usr/lib/postgresql/9.5/bin/postgres  --config-file=/etc/postgresql/9.5/main/postgresql.conf' &

sudo -u postgres psql -c"ALTER user postgres WITH ENCRYPTED PASSWORD 'postgres'"
