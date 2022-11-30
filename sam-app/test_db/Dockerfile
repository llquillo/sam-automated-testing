FROM postgres:9.3-alpine 

WORKDIR /usr/testdb

ADD /schema/user_table.sql /docker-entrypoint-initdb.d/
