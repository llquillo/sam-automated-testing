FROM postgres:9.3

WORKDIR /usr/testdb

# COPY docker-entrypoint-initdb.d .
ADD /schema/user_table.sql /docker-entrypoint-initdb.d/

# copy sql files
# run postgres create/import db -> .sql

# COPY docker-entrypoint-initdb.d .
# COPY ../schema schema

