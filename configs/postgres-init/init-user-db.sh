#!/usr/bin/env bash

# from 
# https://github.com/matthewhegarty/rest-framework-tutorial/blob/postgres-permissions/docker/db/init-user-db.sh

set -e
SCHEMA=app_schema
RW_ROLE=readwrite

echo "creating database"
createdb $DB_NAME

echo "setting default roles"
psql -v ON_ERROR_STOP=1 --dbname "$DB_NAME" <<-EOSQL
    -- lock down permissions on public schema
    -- this prevents any user from creating objects unless given permission
    REVOKE CREATE ON SCHEMA public FROM PUBLIC;

    -- Prevent *any* connection to the new database unless explicitly given
    REVOKE ALL ON DATABASE $DB_NAME FROM PUBLIC;

    -- Create Migrator role
    -- The user is allowed to create databases for the purposes of running the Django test suite.
    CREATE USER $MIGRATOR_DB_USER WITH PASSWORD '$MIGRATOR_DB_PASS' CREATEDB;
    CREATE SCHEMA $SCHEMA AUTHORIZATION $MIGRATOR_DB_USER;

    -- The migrator user must have access to the 'public' schema because that is where new db tables for
    -- the test db will be created
    ALTER ROLE $MIGRATOR_DB_USER SET SEARCH_PATH TO $SCHEMA, public;

    -- Create an Application User role
    -- This user must only be allowed to query the application schema
    CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';
    ALTER ROLE $DB_USER SET SEARCH_PATH TO $SCHEMA;

    -- Create a ROLE which has read / write access to the database
    CREATE ROLE $RW_ROLE;
    GRANT CONNECT ON DATABASE $DB_NAME TO $RW_ROLE;
    GRANT USAGE ON SCHEMA $SCHEMA TO $RW_ROLE;
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA $SCHEMA TO $RW_ROLE;
    GRANT USAGE ON ALL SEQUENCES IN SCHEMA $SCHEMA TO $RW_ROLE;

    -- Grant role privileges to each user
    GRANT $RW_ROLE TO $MIGRATOR_DB_USER;
    GRANT $RW_ROLE TO $DB_USER;

    -- Alter privileges so that the RW Role will be able to access tables created in future
    -- (by the MIGRATOR_DB_USER)
    ALTER DEFAULT PRIVILEGES FOR USER $MIGRATOR_DB_USER GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO $RW_ROLE;
    ALTER DEFAULT PRIVILEGES FOR USER $MIGRATOR_DB_USER GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO $RW_ROLE;
EOSQL
