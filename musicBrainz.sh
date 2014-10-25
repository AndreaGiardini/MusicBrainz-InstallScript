#!/bin/bash

apt-get install -y postgresql postgresql-server-dev-all postgresql-contrib libpq-dev git-core memcached build-essential libxml2-dev libpq-dev libexpat1-dev libdb-dev libicu-dev nginx perl libxml2-dev libpq-dev libexpat1-dev libdb-dev memcached libyaml-perl build-essential git-core libssl-dev libxml2-dev memcached libexpat-dev postgresql-contrib liblocal-lib-perl libossp-uuid-perl libicu-dev
cd /opt
git clone git://github.com/metabrainz/musicbrainz-server.git musicbrainz
cd musicbrainz
git clone git://github.com/metabrainz/postgresql-musicbrainz-collate.git
git clone git://github.com/metabrainz/postgresql-musicbrainz-unaccent.git
cp lib/DBDefs.pm.sample lib/DBDefs.pm

#EDIT FILE lib/DBDefs.pf
#sub REPLICATION_TYPE { RT_SLAVE }
#sub WEB_SERVER { "myserver.com" }
#sub DB_STAGING_SERVER { 0 }
#sub CATALYST_DEBUG { 0 }
#sub DEVELOPMENT_SERVER { 1 }
#sub EMAIL_BUGS { 'myemail@myserver.com' }

cat Makefile.PL | grep ^requires > cpanfile
cpan Carton
carton install --deployment
carton install
carton install --deployment
cpan Catalyst::Plugin::Cache
cd postgresql-musicbrainz-unaccent && make && make install && cd .. 
cd postgresql-musicbrainz-collate && make && make install && cd ..

#MAYBE
echo "local all all trust" > /etc/postgresql/9.1/main/pg_hba.conf

service postgresql restart
wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/20141025-015429/mbdump-editor.tar.bz2
wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/20141025-015429/mbdump-derived.tar.bz2
wget ftp://ftp.musicbrainz.org/pub/musicbrainz/data/fullexport/20141025-015429/mbdump.tar.bz2

#To resolve that login to postgresql with the "postgres" user (or any other
#postgresql user with SUPERUSER privileges) and load the "plpgsql" language
#into the database with the following command:
#
#    postgres=# CREATE LANGUAGE plpgsql;

carton exec ./admin/InitDb.pl --createdb --import mbdump*.tar.bz2 --echo
