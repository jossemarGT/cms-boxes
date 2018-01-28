#!/bin/bash -ex

readonly AS_USER=${1-postgres}
readonly SRCDIR=/home/ubuntu/provision-files

initDBUser() {
  local pswd=${1-notsecure}
  su "$AS_USER" -c "psql -c \"CREATE USER cmsuser WITH PASSWORD '${pswd}';\""
  su "$AS_USER" -c "createdb --username=postgres --owner=cmsuser cmsdb"
  su "$AS_USER" -c "psql --username=postgres --dbname=cmsdb --command='ALTER SCHEMA public OWNER TO cmsuser'"
  su "$AS_USER" -c "psql --username=postgres --dbname=cmsdb --command='GRANT SELECT ON pg_largeobject TO cmsuser'"
}

enableRemoteConnection () {
  # Moving reference files
  mv /etc/postgresql/9.5/main/postgresql.conf{,.back}
  mv /etc/postgresql/9.5/main/pg_hba.conf{,.back}

  # Proviosion our postgresql configurations
  cp ${SRCDIR}/postgresql/* /etc/postgresql/9.5/main
  chown -R postgres:postgres /etc/postgresql/9.5/main

  # Restart service
  systemctl restart postgresql
}

initDBUser "$@"
enableRemoteConnection
